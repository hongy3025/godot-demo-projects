## 灰度后期处理效果节点 —— 使用计算着色器将渲染画面转换为灰度。
##
## 继承自 [CompositorEffect]，作为 Godot 合成器效果使用。
## 在透明物体渲染完成后（POST_TRANSPARENT 阶段），对颜色缓冲区执行灰度化计算着色器。
## 使用 [UniformSetCacheRD] 缓存 uniform set，避免每帧重复创建。
@tool
class_name PostProcessGrayScale
extends CompositorEffect

## 渲染设备实例
var rd: RenderingDevice
## 计算着色器的 RID
var shader: RID
## 计算管线的 RID
var pipeline: RID


## _init 构造函数。设置效果回调类型为透明物体渲染后，获取渲染设备并初始化计算着色器。
func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)


## 引擎通知回调。在节点被销毁前释放着色器资源。
## 释放着色器会自动释放其依赖资源（如 pipeline）。
##
## 参数:
##   what: 通知类型
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			rd.free_rid(shader)


#region 以下代码在渲染线程上执行

## 初始化计算着色器。在渲染线程上编译着色器并创建计算管线。
func _initialize_compute() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		return

	# 编译着色器
	var shader_file := load("res://post_process_grayscale.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()

	shader = rd.shader_create_from_spirv(shader_spirv)
	if shader.is_valid():
		pipeline = rd.compute_pipeline_create(shader)


## 渲染线程每帧调用的回调函数。对每个视图的颜色缓冲区执行灰度化计算着色器。
##
## 参数:
##   p_effect_callback_type: 效果回调类型
##   p_render_data: 渲染数据
func _render_callback(p_effect_callback_type: EffectCallbackType, p_render_data: RenderData) -> void:
	if rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and pipeline.is_valid():
		# 获取渲染场景缓冲区对象，用于访问渲染缓冲区
		var render_scene_buffers := p_render_data.get_render_scene_buffers()
		if render_scene_buffers:
			# 获取 3D 渲染分辨率
			var size: Vector2i = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			# 计算工作组数量（工作组大小为 8x8x1）
			@warning_ignore("integer_division")
			var x_groups := (size.x - 1) / 8 + 1
			@warning_ignore("integer_division")
			var y_groups := (size.y - 1) / 8 + 1
			var z_groups := 1

			# 创建 push constant，必须按 16 字节对齐，顺序与着色器定义一致
			var push_constant := PackedFloat32Array([
					size.x,
					size.y,
					0.0,
					0.0,
				])

			# 遍历所有视图（支持立体渲染，单目渲染无额外开销）
			var view_count: int = render_scene_buffers.get_view_count()
			for view in view_count:
				# 获取颜色图像的 RID，将从中读取并写入
				var input_image: RID = render_scene_buffers.get_color_layer(view)

				# 创建 uniform set（会被缓存，视口配置变化时缓存自动清除）
				var uniform := RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform.binding = 0
				uniform.add_id(input_image)
				var uniform_set := UniformSetCacheRD.get_cache(shader, 0, [uniform])

				# 执行计算着色器
				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_end()
#endregion
