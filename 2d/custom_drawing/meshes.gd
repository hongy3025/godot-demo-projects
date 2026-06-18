## 网格绘制演示 —— 使用 _draw() 方法绘制 3D 网格。
## @tool 脚本使自定义 2D 绘制在编辑器中可见。
@tool
extends Panel

## 未使用但保留定义以避免父节点设置属性时出错。
var use_antialiasing: bool = false

# 必须持有资源的引用作为成员变量或在数组/字典中，否则会被自动释放。
var text_mesh := TextMesh.new()
var noise_texture := NoiseTexture2D.new()
var gradient_texture := GradientTexture2D.new()
var sphere_mesh := SphereMesh.new()
var multi_mesh := MultiMesh.new()

func _ready() -> void:
	text_mesh.text = "TextMesh"
	# 在 2D 中，1 单位 = 1 像素，PrimitiveMesh 的默认大小非常小。
	# 使用更大的网格尺寸或 draw_set_transform() 缩放绘制命令。
	text_mesh.pixel_size = 2.5

	noise_texture.seamless = true
	noise_texture.as_normal_map = true
	noise_texture.noise = FastNoiseLite.new()

	gradient_texture.gradient = Gradient.new()

	sphere_mesh.height = 80.0
	sphere_mesh.radius = 40.0

	multi_mesh.use_colors = true
	multi_mesh.instance_count = 5
	multi_mesh.set_instance_transform_2d(0, Transform2D(0.0, Vector2(0, 0)))
	multi_mesh.set_instance_color(0, Color(1, 0.7, 0.7))
	multi_mesh.set_instance_transform_2d(1, Transform2D(0.0, Vector2(0, 100)))
	multi_mesh.set_instance_color(1, Color(0.7, 1, 0.7))
	multi_mesh.set_instance_transform_2d(2, Transform2D(0.0, Vector2(100, 100)))
	multi_mesh.set_instance_color(2, Color(0.7, 0.7, 1))
	multi_mesh.set_instance_transform_2d(3, Transform2D(0.0, Vector2(100, 0)))
	multi_mesh.set_instance_color(3, Color(1, 1, 0.7))
	multi_mesh.set_instance_transform_2d(4, Transform2D(0.0, Vector2(50, 50)))
	multi_mesh.set_instance_color(4, Color(0.7, 1, 1))
	multi_mesh.mesh = sphere_mesh


func _draw() -> void:
	const margin := Vector2(300, 70)
	var offset := Vector2()

	# 沿 Y 轴翻转绘制，使文本正向显示
	draw_set_transform(margin + offset, 0.0, Vector2(1, -1))
	draw_mesh(text_mesh, noise_texture)

	offset += Vector2(150, 0)
	draw_set_transform(margin + offset)
	draw_mesh(sphere_mesh, noise_texture)

	offset = Vector2(0, 120)
	draw_set_transform(margin + offset)
	draw_multimesh(multi_mesh, gradient_texture)
