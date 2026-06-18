## 高度图生成演示场景的主控制节点 —— 对比 GPU 计算着色器与 CPU 的性能差异。
##
## 继承自 [Control]，提供 UI 界面让用户生成岛屿高度图。
## 支持两种计算方式：
## - GPU 方式：使用计算着色器（RenderingDevice）并行处理
## - CPU 方式：使用 GDScript 逐像素串行处理
## 两种方式都基于噪声生成原始高度图，再应用渐变遮罩生成岛屿形状。
extends Control

## 计算着色器文件的路径（.glsl 文件）
@export_file("*.glsl") var shader_file: String
## 高度图的尺寸（宽度和高度，范围 128~4096，指数级增长）
@export_range(128, 4096, 1, "exp") var dimension: int = 512

## 种子输入控件（SpinBox）的引用
@onready var seed_input: SpinBox = $CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/GridContainer/SeedInput
## 原始噪声高度图显示控件（TextureRect）的引用
@onready var heightmap_rect: TextureRect = $CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/GridContainer/RawHeightmap
## 计算后的岛屿高度图显示控件（TextureRect）的引用
@onready var island_rect: TextureRect = $CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/GridContainer/ComputedHeightmap

## 噪声生成器实例，用于生成原始高度图
var noise: FastNoiseLite
## 渐变对象，用于将圆形遮罩映射为高度衰减
var gradient: Gradient
## 从渐变对象生成的 1D 纹理，用于 GPU 计算
var gradient_tex: GradientTexture1D

## 向上取整到最近 2 的幂的尺寸
var po2_dimensions: int
## 计算开始时间（微秒），用于性能统计
var start_time: int

## GPU 渲染设备实例
var rd: RenderingDevice
## 计算着色器的 RID
var shader_rid: RID
## 高度图纹理的 RID
var heightmap_rid: RID
## 渐变纹理的 RID
var gradient_rid: RID
## uniform set 的 RID
var uniform_set: RID
## 计算管线的 RID
var pipeline: RID


## _init 构造函数。初始化噪声生成器和渐变纹理。
func _init() -> void:
	# 创建噪声函数作为高度图的基础
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_octaves = 5
	noise.fractal_lacunarity = 1.9

	# 创建渐变作为遮罩
	gradient = Gradient.new()
	gradient.add_point(0.6, Color(0.9, 0.9, 0.9, 1.0))
	gradient.add_point(0.8, Color(1.0, 1.0, 1.0, 1.0))
	# 反转渐变：前 70% 从黑过渡到灰，后 30% 从灰过渡到白
	gradient.reverse()

	# 从渐变创建 1D 纹理（单行像素）
	gradient_tex = GradientTexture1D.new()
	gradient_tex.gradient = gradient


## _ready 入口。初始化 UI 和性能信息。
func _ready() -> void:
	randomize_seed()
	po2_dimensions = nearest_po2(dimension)

	noise.frequency = 0.003 / (float(po2_dimensions) / 512.0)

	# 在按钮上显示 GPU 和 CPU 型号名称，方便性能对比
	# 在 CPU 远强于 GPU 的不平衡配置下，计算着色器可能没有优势
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/CreateButtonGPU.text += "\n" + RenderingServer.get_video_adapter_name()
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/CreateButtonCPU.text += "\n" + OS.get_processor_name()


## 引擎通知回调。在节点被销毁前释放 GPU 资源。
##
## 参数:
##   what: 通知类型
func _notification(what: int) -> void:
	# NOTIFICATION_PREDELETE 在引擎删除此节点前触发
	if what == NOTIFICATION_PREDELETE:
		cleanup_gpu()


## 生成随机种子并设置到输入框中。
func randomize_seed() -> void:
	seed_input.value = randi()


## 准备高度图图像。使用噪声生成原始高度图并显示在 UI 上。
##
## 返回: [Image] 原始噪声高度图图像
func prepare_image() -> Image:
	start_time = Time.get_ticks_usec()
	noise.seed = int(seed_input.value)
	# 从噪声生成高度图图像
	var heightmap := noise.get_image(po2_dimensions, po2_dimensions, false, false)

	# 创建缩略图显示在 UI 上（缩放到 512x512，最近邻插值保持像素清晰）
	var clone := Image.new()
	clone.copy_from(heightmap)
	clone.resize(512, 512, Image.INTERPOLATE_NEAREST)
	var clone_tex := ImageTexture.create_from_image(clone)
	heightmap_rect.texture = clone_tex

	return heightmap


## 初始化 GPU 计算资源。创建渲染设备、编译着色器、创建纹理和 uniform set。
## 这些资源创建开销较大，创建后缓存以便后续重复使用。
func init_gpu() -> void:
	# 创建本地渲染设备（运行计算着色器的必要条件）
	rd = RenderingServer.create_local_rendering_device()

	if rd == null:
		OS.alert("""无法在 GPU 上创建本地 RenderingDevice：%s

注意：RenderingDevice 仅在 Forward+ 和 Mobile 渲染模式下可用，Compatibility 模式下不可用。""" % RenderingServer.get_video_adapter_name())
		return

	# 准备着色器
	shader_rid = load_shader(rd, shader_file)

	# 创建高度图纹理格式
	var heightmap_format := RDTextureFormat.new()
	# 有多种格式可选，需要仔细选择正确的格式。
	# 这里将数据解释为红色通道的单字节（R8_UNORM）。
	# 虽然噪声图像只有亮度通道，但可以将其当作红色通道来解释，字节布局完全相同！
	heightmap_format.format = RenderingDevice.DATA_FORMAT_R8_UNORM
	heightmap_format.width = po2_dimensions
	heightmap_format.height = po2_dimensions
	# TextureUsageBits 以位字段存储，表示数据可以用于哪些操作。
	# 由于位字段的特性，可以直接将所需的标志相加：8 + 64 + 128
	heightmap_format.usage_bits = \
			RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
			RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
			RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT

	# 创建高度图纹理（数据稍后设置）
	heightmap_rid = rd.texture_create(heightmap_format, RDTextureView.new())

	# 创建高度图的 uniform
	var heightmap_uniform := RDUniform.new()
	heightmap_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	heightmap_uniform.binding = 0  # 与着色器中的 binding 对应
	heightmap_uniform.add_id(heightmap_rid)

	# 创建渐变纹理格式
	var gradient_format := RDTextureFormat.new()
	# 渐变也可以像高度图一样转换为单通道，但这里使用四通道（RGBA）作为示例
	gradient_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	gradient_format.width = gradient_tex.width  # 默认 256
	# GradientTexture1D 的高度始终为 1
	gradient_format.height = 1
	gradient_format.usage_bits = \
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT

	# 将渐变数据存储为纹理
	gradient_rid = rd.texture_create(gradient_format, RDTextureView.new(), [gradient_tex.get_image().get_data()])

	# 创建渐变的 uniform
	var gradient_uniform := RDUniform.new()
	gradient_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	gradient_uniform.binding = 1  # 与着色器中的 binding 对应
	gradient_uniform.add_id(gradient_rid)

	uniform_set = rd.uniform_set_create([heightmap_uniform, gradient_uniform], shader_rid, 0)

	pipeline = rd.compute_pipeline_create(shader_rid)


## 使用 GPU 计算着色器生成岛屿高度图。
##
## 参数:
##   heightmap: 原始噪声高度图图像
func compute_island_gpu(heightmap: Image) -> void:
	if rd == null:
		init_gpu()

	if rd == null:
		$CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer2/Label2.text = \
			"当前渲染驱动不支持 RenderingDevice"
		return

	# 将高度图数据上传到 GPU 纹理
	rd.texture_update(heightmap_rid, 0, heightmap.get_data())

	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	# 核心计算逻辑！着色器的工作组大小为 8x8x1，
	# 这里为每个 8x8 像素块分派一个工作组。这个比例高度可调，性能可能有所不同。
	@warning_ignore("integer_division")
	rd.compute_list_dispatch(compute_list, po2_dimensions / 8, po2_dimensions / 8, 1)
	rd.compute_list_end()

	rd.submit()
	# 等待 GPU 完成计算
	# 通常会让计算着色器在后台运行，等几帧后再同步，这里为简单直接同步
	rd.sync()

	# 获取 GPU 处理后的数据
	var output_bytes := rd.texture_get_data(heightmap_rid, 0)
	# GPU 将每个字节当作红色通道处理，这里将数据解释为亮度通道
	var island_img := Image.create_from_data(po2_dimensions, po2_dimensions, false, Image.FORMAT_L8, output_bytes)

	display_island(island_img)


## 释放所有 GPU 资源，避免内存泄漏。
func cleanup_gpu() -> void:
	if rd == null:
		return

	rd.free_rid(pipeline)
	pipeline = RID()

	rd.free_rid(uniform_set)
	uniform_set = RID()

	rd.free_rid(gradient_rid)
	gradient_rid = RID()

	rd.free_rid(heightmap_rid)
	heightmap_rid = RID()

	rd.free_rid(shader_rid)
	shader_rid = RID()

	rd.free()
	rd = null


## 导入、编译并加载着色器，返回着色器的 RID。
##
## 参数:
##   p_rd: 渲染设备实例
##   path: 着色器文件路径
## 返回: 着色器的 RID
func load_shader(p_rd: RenderingDevice, path: String) -> RID:
	var shader_file_data: RDShaderFile = load(path)
	var shader_spirv: RDShaderSPIRV = shader_file_data.get_spirv()
	return p_rd.shader_create_from_spirv(shader_spirv)


## 使用 CPU 逐像素计算岛屿高度图（计算着色器的 CPU 对照实现）。
##
## 参数:
##   heightmap: 原始噪声高度图图像
func compute_island_cpu(heightmap: Image) -> void:
	# 此函数对应 compute_shader.glsl 中 main() 函数的 CPU 实现
	var center := Vector2i(po2_dimensions, po2_dimensions) / 2
	# 遍历图像中的所有像素坐标
	for y in range(0, po2_dimensions):
		for x in range(0, po2_dimensions):
			var coord := Vector2i(x, y)
			var pixel := heightmap.get_pixelv(coord)
			# 计算当前像素到中心的距离
			var distance := Vector2(center).distance_to(Vector2(coord))
			# 由于 X 和 Y 维度相同，可以用 center.x 作为中心到边缘的距离
			var gradient_color := gradient.sample(distance / float(center.x))
			# 使用像素的 v（明度）值（与计算着色器中的亮度不完全相同，但足够接近）
			pixel.v *= gradient_color.v
			if pixel.v < 0.2:
				pixel.v = 0.0
			heightmap.set_pixelv(coord, pixel)
	display_island(heightmap)


## 在 UI 上显示计算后的岛屿高度图，并更新耗时统计。
##
## 参数:
##   island: 计算后的岛屿高度图图像
func display_island(island: Image) -> void:
	# 创建 ImageTexture 在 UI 上显示
	var island_tex := ImageTexture.create_from_image(island)
	island_rect.texture = island_tex

	# 计算并显示耗时
	var stop_time := Time.get_ticks_usec()
	var elapsed := stop_time - start_time
	$CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer/Label2.text = "%s ms" % str(elapsed * 0.001).pad_decimals(1)


## "随机"按钮点击回调。重新生成随机种子。
func _on_random_button_pressed() -> void:
	randomize_seed()


## "GPU 生成"按钮点击回调。使用 GPU 计算着色器生成岛屿高度图。
## 使用 call_deferred 延迟执行，避免阻塞 UI 线程。
func _on_create_button_gpu_pressed() -> void:
	var heightmap := prepare_image()
	compute_island_gpu.call_deferred(heightmap)


## "CPU 生成"按钮点击回调。使用 CPU 逐像素生成岛屿高度图。
## 使用 call_deferred 延迟执行，避免阻塞 UI 线程。
func _on_create_button_cpu_pressed() -> void:
	var heightmap := prepare_image()
	compute_island_cpu.call_deferred(heightmap)
