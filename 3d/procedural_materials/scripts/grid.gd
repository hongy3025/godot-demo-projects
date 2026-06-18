## 程序化网格纹理生成器 —— 在运行时创建网格纹理并应用到材质。
##
## 继承自 [MeshInstance3D]，在 _ready 时通过代码生成网格纹理，
## 包括网格线、随机噪声，并生成法线贴图。
## 不使用 `@tool` 以避免将原始图像数据保存到场景文件中（会大幅增加文件大小）。
extends MeshInstance3D


## 纹理大小。
const TEXTURE_SIZE = Vector2i(512, 512)
## 网格间距。
const GRID_SIZE = 32
## 网格线厚度。
const GRID_THICKNESS = 4


## _ready 入口。生成纹理并应用到材质。
func _ready() -> void:
	var image := Image.create(TEXTURE_SIZE.x, TEXTURE_SIZE.y, false, Image.FORMAT_RGB8)
	# 使用一维循环（比嵌套循环更快）。
	for i in TEXTURE_SIZE.x * TEXTURE_SIZE.y:
		var x := i % TEXTURE_SIZE.y
		var y := i / TEXTURE_SIZE.y
		var color := Color()

		# 绘制网格，在 X 和 Y 线交汇处增加对比度。
		# 居中网格线使所有纹理边缘都能看到线条。
		if (x + GRID_THICKNESS / 2) % GRID_SIZE < GRID_THICKNESS and (y + GRID_THICKNESS / 2) % GRID_SIZE < GRID_THICKNESS:
			color.g = 0.8
		elif (x + GRID_THICKNESS / 2) % GRID_SIZE < GRID_THICKNESS or (y + GRID_THICKNESS / 2) % GRID_SIZE < GRID_THICKNESS:
			color.g = 0.25

		# 添加随机噪声增加细节。
		color += Color(randf(), randf(), randf()) * 0.1

		image.set_pixel(x, y, color)

	image.generate_mipmaps()
	var image_texture := ImageTexture.create_from_image(image)
	get_surface_override_material(0).albedo_texture = image_texture

	# 从漫反射贴图生成法线贴图。
	image.bump_map_to_normal_map(5.0)
	image.generate_mipmaps()
	var image_texture_normal := ImageTexture.create_from_image(image)
	get_surface_override_material(0).normal_texture = image_texture_normal
