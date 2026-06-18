@tool
## 中性 3D LUT 生成器 —— 创建输入颜色等于输出颜色的中性查找纹理。
##
## 继承自 [EditorScript]，可在脚本编辑器中运行（文件 > 运行 或 Ctrl+Shift+X）。
## 生成的中性 LUT 用于环境颜色校正时不会明显改变渲染效果。
## 低分辨率 LUT（如 17×17×17 和 33×33×33）由于双线性过滤限制仍会略微影响渲染。
extends EditorScript

## 创建中性 LUT 纹理。
##
## 参数:
##   name: 文件名
##   size: LUT 大小（每个维度）
##   vertical: 是否为垂直布局
func create_neutral_lut(name: String, size: int, vertical: bool):
	var image = Image.create_empty(
			size if vertical else (size * size),
			(size * size) if vertical else size,
			false,
			Image.FORMAT_RGB8
		)

	for z in size:
		var x_offset := int(z * size) if not vertical else 0
		var y_offset := int(z * size) if vertical else 0
		for x in size:
			for y in size:
				# 舍入偏置 +0.2 以更中性（该偏置通过经验确定）。
				image.set_pixel(x_offset + x, y_offset + y, Color8(
						roundi(((x + 0.2) / float(size - 1)) * 255),
						roundi(((y + 0.2) / float(size - 1)) * 255),
						roundi(((z + 0.2) / float(size - 1)) * 255)
					))

	image.save_png("user://" + name + ".png")


## 运行脚本。生成多种分辨率的中性 LUT。
func _run() -> void:
	create_neutral_lut("lut_neutral_17x17x17_horizontal", 17, false)
	create_neutral_lut("lut_neutral_33x33x33_horizontal", 33, false)
	create_neutral_lut("lut_neutral_51x51x51_horizontal", 51, false)
	create_neutral_lut("lut_neutral_65x65x65_horizontal", 65, false)
	create_neutral_lut("lut_neutral_17x17x17_vertical", 17, true)
	create_neutral_lut("lut_neutral_33x33x33_vertical", 33, true)
	create_neutral_lut("lut_neutral_51x51x51_vertical", 51, true)
	create_neutral_lut("lut_neutral_65x65x65_vertical", 65, true)

	# 打开目标文件夹。
	# 在项目中导入纹理后，记得在导入面板中将导入模式改为 Texture3D，
	# 并设置水平/垂直切片数。
	OS.shell_open(ProjectSettings.globalize_path("user://"))
