## 水面波纹效果节点 —— 使用计算着色器实现经典的水面波纹模拟。
##
## 继承自 [Area3D]，通过计算着色器在 GPU 上模拟水面波纹扩散和衰减效果。
## 支持鼠标交互（点击水面产生波纹）和自动降雨（随机产生雨滴波纹）两种模式。
## 利用 Godot 的 RenderingDevice API 和自定义纹理（Custom Texture RD）实现。
## 如果引擎线程模型设置为多线程，计算相关代码会在渲染线程上执行。
@tool
extends Area3D

## 雨滴波纹的大小（像素单位）
@export var rain_size: float = 3.0
## 鼠标点击产生的波纹大小（像素单位）
@export var mouse_size: float = 5.0
## 波纹纹理的分辨率（宽度 x 高度）
@export var texture_size: Vector2i = Vector2i(512, 512)
## 波纹阻尼系数，控制波纹衰减速度。范围 1.0 ~ 10.0
@export_range(1.0, 10.0, 0.1) var damp: float = 1.0

## 计时器累计时间，用于控制雨滴生成的间隔
var t := 0.0
## 雨滴生成的最大间隔时间（秒）
var max_t := 0.1

## 当前显示给材质的纹理对象（Texture2DRD）
var texture: Texture2DRD
## 下一帧要渲染到的纹理索引（0/1/2 循环）
var next_texture: int = 0

## 传递给计算着色器的波纹参数。
## x: 波纹在纹理上的 X 坐标
## y: 波纹在纹理上的 Y 坐标
## z: 波纹大小（雨滴或鼠标）
## w: 标记位（1.0 表示鼠标在水面上方，0.0 表示未悬停）
var add_wave_point: Vector4
## 鼠标在屏幕上的全局位置
var mouse_pos: Vector2
## 鼠标左键是否按下
var mouse_pressed: bool = false


## _ready 入口。在渲染线程上初始化计算着色器资源，并从材质中获取纹理对象。
func _ready() -> void:
	# 如果计算代码需要在渲染线程上运行，初始化也必须在渲染线程上完成
	RenderingServer.call_on_render_thread(_initialize_compute_code.bind(texture_size))

	# 从 MeshInstance3D 的材质覆写中获取纹理对象
	var material: ShaderMaterial = $MeshInstance3D.material_override
	if material:
		material.set_shader_parameter(&"effect_texture_size", texture_size)

		# 获取纹理对象引用
		texture = material.get_shader_parameter(&"effect_texture")


## 节点退出场景树时的清理工作。释放纹理 RID 和计算着色器资源。
func _exit_tree() -> void:
	# 确保清理纹理的 RID
	if texture:
		texture.texture_rd_rid = RID()

	RenderingServer.call_on_render_thread(_free_compute_resources)


## 处理未处理的输入事件。记录鼠标位置和左键按下状态。
##
## 参数:
##   input_event: 输入事件对象
func _unhandled_input(input_event: InputEvent) -> void:
	# 在编辑器中不处理输入
	if Engine.is_editor_hint():
		return

	# 记录鼠标位置
	if input_event is InputEventMouseMotion or input_event is InputEventMouseButton:
		mouse_pos = input_event.global_position

	# 记录鼠标左键按下/释放状态
	if input_event is InputEventMouseButton and input_event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		mouse_pressed = input_event.pressed


## 检测鼠标是否悬停在水面区域上，并计算对应的纹理坐标。
## 通过射线检测（RayCast）判断鼠标与水面区域的交点，
## 将交点从世界坐标转换到局部坐标，再映射到纹理像素坐标。
func _check_mouse_pos() -> void:
	# 获取当前 3D 摄像机
	var camera := get_viewport().get_camera_3d()

	# 创建物理射线查询参数
	var parameters := PhysicsRayQueryParameters3D.new()
	parameters.from = camera.project_ray_origin(mouse_pos)
	parameters.to = parameters.from + camera.project_ray_normal(mouse_pos) * 100.0
	parameters.collision_mask = 1
	parameters.collide_with_bodies = false
	parameters.collide_with_areas = true

	# 执行射线检测
	var result := get_world_3d().direct_space_state.intersect_ray(parameters)
	if not result.is_empty():
		# 将交点从世界坐标转换到水面节点的局部坐标
		var pos: Vector3 = global_transform.affine_inverse() * result.position
		# 将局部坐标映射到纹理像素坐标（水面大小为 5x5 单位）
		add_wave_point.x = clamp(pos.x / 5.0, -0.5, 0.5) * texture_size.x + 0.5 * texture_size.x
		add_wave_point.y = clamp(pos.z / 5.0, -0.5, 0.5) * texture_size.y + 0.5 * texture_size.y
		# 使用 w 分量标记鼠标悬停在水面上方
		add_wave_point.w = 1.0
	else:
		add_wave_point.x = 0.0
		add_wave_point.y = 0.0
		add_wave_point.w = 0.0


## 每帧更新逻辑。处理鼠标交互和雨滴动画，并触发计算着色器渲染。
##
## 参数:
##   delta: 上一帧到当前帧的时间间隔（秒）
func _process(delta: float) -> void:
	# 在编辑器中忽略鼠标输入
	if Engine.is_editor_hint():
		add_wave_point.w = 0.0
	else:
		# 检测鼠标与水面区域的交点
		_check_mouse_pos()

	# 如果鼠标不在水面上方，则模拟雨滴效果
	if add_wave_point.w == 0.0:
		t += delta
		if t > max_t:
			t = 0
			# 在随机位置生成雨滴波纹
			add_wave_point.x = randi_range(0, texture_size.x)
			add_wave_point.y = randi_range(0, texture_size.y)
			add_wave_point.z = rain_size
		else:
			add_wave_point.z = 0.0
	else:
		# 鼠标在水面上方时，根据按键状态设置波纹大小
		add_wave_point.z = mouse_size if mouse_pressed else 0.0

	# 循环切换下一帧要写入的纹理索引（0 -> 1 -> 2 -> 0）
	next_texture = (next_texture + 1) % 3

	# 更新材质的纹理引用，显示上一帧计算完成的结果
	if texture:
		texture.texture_rd_rid = texture_rds[next_texture]

	# 在渲染线程上执行计算着色器
	# 注意：_render_process 在纹理被使用之前执行，所以 next_rd 会被正确填充
	RenderingServer.call_on_render_thread(_render_process.bind(next_texture, add_wave_point, texture_size, damp))


###############################################################################
## 以下代码全部在渲染线程上执行

## 渲染设备实例，用于执行计算着色器
var rd: RenderingDevice

## 计算着色器的 RID
var shader: RID
## 计算管线的 RID
var pipeline: RID

## 3 张纹理的 RID 数组，用于双缓冲/三缓冲机制：
## - 当前帧要写入的纹理
## - 上一帧的结果纹理
## - 上上一帧的结果纹理
var texture_rds: Array[RID] = [RID(), RID(), RID()]
## 9 个 uniform set 的 RID 数组（3 种纹理组合 × 3 个 uniform set）
var texture_sets: Array[RID] = [RID(), RID(), RID(), RID(), RID(), RID(), RID(), RID(), RID()]


## 创建单个 uniform set，将纹理绑定到着色器的指定 set 索引。
##
## 参数:
##   texture_rd: 纹理的 RID
##   uniform_set: uniform set 的索引
## 返回: 创建的 uniform set 的 RID
func _create_uniform_set(texture_rd: RID, uniform_set: int) -> RID:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = 0
	uniform.add_id(texture_rd)
	return rd.uniform_set_create([uniform], shader, uniform_set)


## 初始化计算着色器代码和纹理资源。在渲染线程上调用。
##
## 参数:
##   init_with_texture_size: 纹理的初始化尺寸
func _initialize_compute_code(init_with_texture_size: Vector2i) -> void:
	# 获取主渲染设备的 RenderingDevice
	rd = RenderingServer.get_rendering_device()

	# 加载并编译计算着色器
	var shader_file := load("res://water_plane/water_compute.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)

	# 创建 3 张纹理用于波纹模拟（三缓冲）
	var tf: RDTextureFormat = RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf.width = init_with_texture_size.x
	tf.height = init_with_texture_size.y
	tf.depth = 1
	tf.array_layers = 1
	tf.mipmaps = 1
	tf.usage_bits = (
			RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT |
			RenderingDevice.TEXTURE_USAGE_STORAGE_BIT |
			RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
		)

	for i in 3:
		# 创建纹理
		texture_rds[i] = rd.texture_create(tf, RDTextureView.new(), [])

		# 清空纹理数据
		rd.texture_clear(texture_rds[i], Color(0, 0, 0, 0), 0, 1, 0, 1)

	# 确保 3 张纹理都初始化完成后，再创建 uniform set
	# 每个纹理组合包含：当前帧、上一帧、下一帧
	for i in 3:
		var next_texture_rd := texture_rds[i]
		var current_texture_rd := texture_rds[(i + 2) % 3]
		var previous_texture_rd := texture_rds[(i + 1) % 3]

		texture_sets[i * 3 + 0] = _create_uniform_set(current_texture_rd, 0)
		texture_sets[i * 3 + 1] = _create_uniform_set(previous_texture_rd, 1)
		texture_sets[i * 3 + 2] = _create_uniform_set(next_texture_rd, 2)


## 执行计算着色器进行波纹模拟。在渲染线程上每帧调用。
##
## 参数:
##   with_next_texture: 下一帧要写入的纹理索引
##   wave_point: 波纹参数（位置 x/y、大小 z、标记 w）
##   tex_size: 纹理尺寸
##   p_damp: 阻尼系数
func _render_process(with_next_texture: int, wave_point: Vector4, tex_size: Vector2i, p_damp: float) -> void:
	# GDScript 暂不支持结构体，所以手动构建 push constant 数据
	var push_constant := PackedFloat32Array()
	push_constant.push_back(wave_point.x)
	push_constant.push_back(wave_point.y)
	push_constant.push_back(wave_point.z)
	push_constant.push_back(wave_point.w)

	push_constant.push_back(tex_size.x)
	push_constant.push_back(tex_size.y)
	push_constant.push_back(p_damp)
	push_constant.push_back(0.0)

	# 计算工作组数量。使用 (n - 1) / 8 + 1 确保纹理尺寸不能被 8 整除时也能覆盖全部像素。
	# 着色器内部会通过 discard 检查处理边界情况。
	@warning_ignore("integer_division")
	var x_groups := (tex_size.x - 1) / 8 + 1
	@warning_ignore("integer_division")
	var y_groups := (tex_size.y - 1) / 8 + 1

	# 根据纹理索引选择对应的 uniform set
	var current_set := texture_sets[with_next_texture * 3]
	var previous_set := texture_sets[with_next_texture * 3 + 1]
	var next_set := texture_sets[with_next_texture * 3 + 2]

	if not (pipeline.is_valid() and current_set.is_valid() and previous_set.is_valid() and next_set.is_valid()):
		return

	# 执行计算着色器
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, current_set, 0)
	rd.compute_list_bind_uniform_set(compute_list, previous_set, 1)
	rd.compute_list_bind_uniform_set(compute_list, next_set, 2)
	rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
	rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
	rd.compute_list_end()

	# 不需要手动同步，Godot 的默认屏障会自动处理。
	# 如果计算着色器的输出要作为另一个计算着色器的输入，需要添加屏障：
	# rd.barrier(RenderingDevice.BARRIER_MASK_COMPUTE)


## 释放计算着色器相关的所有 GPU 资源。
## uniform set 和 pipeline 作为依赖资源会被自动清理。
func _free_compute_resources() -> void:
	for i in 3:
		if texture_rds[i]:
			rd.free_rid(texture_rds[i])

	for i in 9:
		if texture_sets[i] and texture_sets[i].is_valid():
			rd.free_rid(texture_sets[i])

	if shader:
		rd.free_rid(shader)
