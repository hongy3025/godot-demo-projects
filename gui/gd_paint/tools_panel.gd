## 工具面板 —— 简易画图程序的工具栏。
## 继承自 [Panel]，管理画笔工具选择、颜色设置、画布操作（撤销/保存/清空）等。
extends Panel

## 画笔设置面板的引用。
@onready var brush_settings: Control = $BrushSettings
## 画笔大小标签引用。
@onready var label_brush_size: Label = brush_settings.get_node(^"LabelBrushSize")
## 画笔形状标签引用。
@onready var label_brush_shape: Label = brush_settings.get_node(^"LabelBrushShape")
## 状态统计标签引用，显示画笔对象数量。
@onready var label_stats: Label = $LabelStats
## 当前工具名称标签引用。
@onready var label_tools: Label = $LabelTools

## 父节点引用。
@onready var _parent: Control = get_parent()
## 保存文件对话框引用。
@onready var save_dialog: FileDialog = _parent.get_node(^"SaveFileDialog")
## 画布控件引用。
@onready var paint_control: Control = _parent.get_node(^"PaintControl")


## _ready 入口：连接所有按钮和控件的信号。
func _ready() -> void:
	# 连接操作按钮信号。
	$ButtonUndo.pressed.connect(button_pressed.bind("undo_stroke"))
	$ButtonSave.pressed.connect(button_pressed.bind("save_picture"))
	$ButtonClear.pressed.connect(button_pressed.bind("clear_picture"))

	# 连接画笔工具按钮信号。
	$ButtonToolPencil.pressed.connect(button_pressed.bind("mode_pencil"))
	$ButtonToolEraser.pressed.connect(button_pressed.bind("mode_eraser"))
	$ButtonToolRectangle.pressed.connect(button_pressed.bind("mode_rectangle"))
	$ButtonToolCircle.pressed.connect(button_pressed.bind("mode_circle"))
	$BrushSettings/ButtonShapeBox.pressed.connect(button_pressed.bind("shape_rectangle"))
	$BrushSettings/ButtonShapeCircle.pressed.connect(button_pressed.bind("shape_circle"))

	# 连接颜色选择器和画笔设置信号。
	$ColorPickerBrush.color_changed.connect(brush_color_changed)
	$ColorPickerBackground.color_changed.connect(background_color_changed)
	$BrushSettings/HScrollBarBrushSize.value_changed.connect(brush_size_changed)

	# 连接保存文件对话框的文件选择信号。
	save_dialog.file_selected.connect(save_file_selected)


## _physics_process 物理帧更新：更新状态标签，显示当前画笔对象数量。
func _physics_process(_delta: float) -> void:
	label_stats.text = "Brush objects: %d" % paint_control.brush_data_list.size()


## 按钮点击统一处理函数。根据按钮名称执行对应的操作。
##
## 参数:
##   button_name: 按钮名称字符串，决定执行的操作类型
##     画笔模式: mode_pencil / mode_eraser / mode_rectangle / mode_circle
##     画笔形状: shape_rectangle / shape_circle
##     操作: clear_picture / save_picture / undo_stroke
func button_pressed(button_name: String) -> void:
	var tool_name: String = ""
	var shape_name: String = ""

	if button_name == "mode_pencil":
		paint_control.brush_mode = paint_control.BrushMode.PENCIL
		brush_settings.modulate = Color(1, 1, 1)
		tool_name = "Pencil"
	elif button_name == "mode_eraser":
		paint_control.brush_mode = paint_control.BrushMode.ERASER
		brush_settings.modulate = Color(1, 1, 1)
		tool_name = "Eraser"
	elif button_name == "mode_rectangle":
		paint_control.brush_mode = paint_control.BrushMode.RECTANGLE_SHAPE
		brush_settings.modulate = Color(1, 1, 1, 0.5)
		tool_name = "Rectangle shape"
	elif button_name == "mode_circle":
		paint_control.brush_mode = paint_control.BrushMode.CIRCLE_SHAPE
		brush_settings.modulate = Color(1, 1, 1, 0.5)
		tool_name = "Circle shape"

	# 画笔形状按钮处理
	elif button_name == "shape_rectangle":
		paint_control.brush_shape = paint_control.BrushShape.RECTANGLE
		shape_name = "Rectangle"
	elif button_name == "shape_circle":
		paint_control.brush_shape = paint_control.BrushShape.CIRCLE
		shape_name = "Circle"

	# 操作按钮处理
	elif button_name == "clear_picture":
		paint_control.brush_data_list.clear()
		paint_control.queue_redraw()
	elif button_name == "save_picture":
		save_dialog.popup_centered()
	elif button_name == "undo_stroke":
		paint_control.undo_stroke()

	# 更新工具名称和画笔形状标签
	if not tool_name.is_empty():
		label_tools.text = "Selected tool: %s" % tool_name
	if not shape_name.is_empty():
		label_brush_shape.text = "Brush shape: %s" % shape_name


## 画笔颜色变化回调：将颜色选择器的颜色同步到画布控件。
func brush_color_changed(color: Color) -> void:
	paint_control.brush_color = color


## 背景颜色变化回调：更新背景面板颜色和画布控件的背景色。
## 由于橡皮擦的工作方式，还需要重绘画布。
func background_color_changed(color: Color) -> void:
	get_parent().get_node(^"DrawingAreaBG").modulate = color
	paint_control.bg_color = color
	paint_control.queue_redraw()


## 画笔大小变化回调：更新画笔大小并刷新标签显示。
func brush_size_changed(value: float) -> void:
	paint_control.brush_size = ceilf(value)
	label_brush_size.text = "Brush size: " + str(ceil(value)) + "px"


## 保存文件选择回调：将选择的路径传递给画布控件执行保存。
func save_file_selected(path: String) -> void:
	paint_control.save_picture(path)
