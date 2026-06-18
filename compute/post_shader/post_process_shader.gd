## 可编程后期处理着色器效果节点 —— 支持运行时编辑和重编译计算着色器。
##
## 继承自 [CompositorEffect]，作为 Godot 合成器效果使用。
## 与 [PostProcessGrayScale] 不同，此节点允许在运行时通过 [shader_code] 属性
## 动态修改着色器代码，并自动重编译。着色器代码会被嵌入到 [TEMPLATE_SHADER] 模板中，
## 模板提供了场景数据、颜色图像、深度纹理等上下文。
@tool
class_name PostProcessShader
extends CompositorEffect

## 着色器模板。用户代码通过 #COMPUTE_CODE 占位符嵌入。
## 模板包含：
## - 场景数据块（SceneData）：当前帧和上一帧的渲染数据
## - color_image：颜色缓冲区图像（可读写）
## - depth_texture：深度纹理（只读）
## - push constant：光栅化尺寸和视图索引
const TEMPLATE_SHADER: String = """#version 450

#define MAX_VIEWS 2

#include "godot/scene_data_inc.glsl"

// 工作组大小（x, y, z）维度
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, std140) uniform SceneDataBlock {
	SceneData data;
	SceneData prev_data;
}
scene_data_block;

layout(rgba16f, set = 0, binding = 1) uniform image2D color_image;
layout(set = 0, binding = 2) uniform sampler2D depth_texture;

// push constant，必须按 16 字节对齐，与脚本中传递的顺序一致
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	float view;
	float pad;
} params;

// 每个线程执行的代码
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);
	int view = int(params.view);

	if (uv.x >= size.x || uv.y >= size.y) {
		return;
	}

	vec2 uv_norm = vec2(uv) / params.raster_size;

	vec4 color = imageLoad(color_image, uv);
	float depth = texture(depth_texture, uv_norm).r;

	#COMPUTE_CODE

	imageStore(color_image, uv, color);
}"""

## 用户自定义的着色器代码（多行文本），将在运行时嵌入模板并编译。
## 设置时会标记着色器为"脏"状态，下一帧自动重编译。
@export_multiline var shader_code: String = "":
	set(value):
		mutex.lock()
		shader_code = value
		shader_is_dirty = true
		mutex.unlock()

## 渲染设备实例
var rd: RenderingDevice
## 计算着色器的 RID
var shader: RID
## 计算管线的 RID
var pipeline: RID
## 最近邻采样器的 RID，用于深度纹理采样
var nearest_sampler: RID

## 互斥锁，保护 shader_code 和 shader_is_dirty 的线程安全访问
var mutex := Mutex.new()
## 标记着色器是否需要重新编译
var shader_is_dirty: bool = true


## _init 构造函数。设置效果回调类型为透明物体渲染后，获取渲染设备。
func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()


## 引擎通知回调。在节点被销毁前释放着色器和采样器资源。
## 释放着色器会自动释放其依赖资源（如 pipeline）。
##
## 参数:
##   what: 通知类型
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			RenderingServer.free_rid(shader)
		if nearest_sampler.is_valid():
			rd.free_rid(nearest_sampler)


#region 以下代码在渲染线程上执行

## 检查着色器是否需要重新编译。如果着色器代码被修改，则重新编译并创建新的管线。
##
## 返回: [bool] 管线是否有效
func _check_shader() -> bool:
	if not rd:
		return false

	var new_shader_code: String = ""

	# 检查着色器是否脏了
	mutex.lock()
	if shader_is_dirty:
		new_shader_code = shader_code
		shader_is_dirty = false
	mutex.unlock()

	# 没有新的着色器代码
	if new_shader_code.is_empty():
		return pipeline.is_valid()

	# 将用户代码嵌入模板
	new_shader_code = TEMPLATE_SHADER.replace("#COMPUTE_CODE", new_shader_code);

	# 释放旧的着色器资源
	if shader.is_valid():
		rd.free_rid(shader)
		shader = RID()
		pipeline = RID()

	# 编译新的着色器
	var shader_source := RDShaderSource.new()
	shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
	shader_source.source_compute = new_shader_code
	var shader_spirv: RDShaderSPIRV = rd.shader_compile_spirv_from_source(shader_source)

	if shader_spirv.compile_error_compute != "":
		push_error(shader_spirv.compile_error_compute)
		push_error("代码：\n" + new_shader_code)
		return false

	shader = rd.shader_create_from_spirv(shader_spirv)
	if not shader.is_valid():
		return false

	pipeline = rd.compute_pipeline_create(shader)

	return pipeline.is_valid()


## 渲染线程每帧调用的回调函数。对每个视图执行用户自定义的计算着色器。
## 支持访问场景数据、颜色缓冲区和深度缓冲区。
##
## 参数:
##   p_effect_callback_type: 效果回调类型
##   p_render_data: 渲染数据
func _render_callback(p_effect_callback_type: EffectCallbackType, p_render_data: RenderData) -> void:
	if rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and _check_shader():
		# 获取渲染场景缓冲区对象和场景数据对象
		var render_scene_buffers: RenderSceneBuffers = p_render_data.get_render_scene_buffers()
		var scene_data: RenderSceneData = p_render_data.get_render_scene_data()
		if render_scene_buffers and scene_data:
			# 获取 3D 渲染分辨率
			var size: Vector2i = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			# 计算工作组数量（工作组大小为 8x8x1）
			@warning_ignore("integer_division")
			var x_groups: int = (size.x - 1) / 8 + 1
			@warning_ignore("integer_division")
			var y_groups: int = (size.y - 1) / 8 + 1
			var z_groups: int = 1

			# 创建 push constant，必须按 16 字节对齐，顺序与着色器定义一致
			var push_constant := PackedFloat32Array([
					size.x,
					size.y,
					0.0,
					0.0,
				])

			# 确保采样器已创建
			if not nearest_sampler.is_valid():
				var sampler_state: RDSamplerState = RDSamplerState.new()
				sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
				sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
				nearest_sampler = rd.sampler_create(sampler_state)

			# 遍历所有视图（支持立体渲染，单目渲染无额外开销）
			var view_count: int = render_scene_buffers.get_view_count()
			for view in view_count:
				# 获取场景数据缓冲区的 RID
				var scene_data_buffers: RID = scene_data.get_uniform_buffer()

				# 获取颜色图像的 RID（可读写）
				var color_image: RID = render_scene_buffers.get_color_layer(view)

				# 获取深度图像的 RID（只读）
				var depth_image: RID = render_scene_buffers.get_depth_layer(view)

				# 创建 uniform set（会被缓存，视口配置变化时缓存自动清除）
				var scene_data_uniform := RDUniform.new()
				scene_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
				scene_data_uniform.binding = 0
				scene_data_uniform.add_id(scene_data_buffers)
				var color_uniform := RDUniform.new()
				color_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				color_uniform.binding = 1
				color_uniform.add_id(color_image)
				var depth_uniform := RDUniform.new()
				depth_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
				depth_uniform.binding = 2
				depth_uniform.add_id(nearest_sampler)
				depth_uniform.add_id(depth_image)
				var uniform_set_rid: RID = UniformSetCacheRD.get_cache(shader, 0, [scene_data_uniform, color_uniform, depth_uniform])

				# 设置当前视图索引
				push_constant[2] = view

				# 执行计算着色器
				var compute_list: int = rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set_rid, 0)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_end()
#endregion
