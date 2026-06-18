## 画布控件 —— 简易画图程序的核心绘图引擎。
## 继承自 [Control]，管理画笔数据、处理鼠标输入、执行绘制和保存操作。
extends Control

## 画笔模式枚举：定义不同的绘图工具类型。
enum BrushMode {
	PENCIL,       # 铅笔模式：自由绘制
	ERASER,       # 橡皮擦模式：擦除（实际用背景色覆盖）
	CIRCLE_SHAPE, # 圆形形状：绘制空心圆
	RECTANGLE_SHAPE, # 矩形形状：绘制空心矩形
}

## 画笔形状枚举：定义铅笔和橡皮擦的笔触形状。
enum BrushShape {
	RECTANGLE, # 矩形笔触
	CIRCLE,    # 圆形笔触
}

## 撤销模式常量：表示需要撤销的是一个形状（圆形或矩形）。
const UNDO_MODE_SHAPE = -2
## 无撤销常量：表示没有可撤销的操作。
const UNDO_NONE = -1

## 存储所有画笔数据的字典列表。每个字典包含一次笔触的完整信息。
var brush_data_list: Array[Dictionary] = []

## 鼠标是否在绘图区域内。
var is_mouse_in_drawing_area: bool = false
## 上一帧的鼠标位置，用于计算绘制间距。
var last_mouse_pos := Vector2()
## 鼠标左键按下时的起始位置，用于形状绘制。
var mouse_click_start_pos := Vector2.INF

## 是否已设置撤销点，防止同一笔触重复设置。
var undo_set: bool = false
## 撤销元素列表编号，记录当前笔触开始前 brush_data_list 的大小。
var undo_element_list_num := -1

## 当前画笔模式。
var brush_mode := BrushMode.PENCIL
## 当前画笔大小（像素）。
var brush_size := 32
## 当前画笔颜色。
var brush_color := Color.BLACK
## 当前画笔形状。
var brush_shape := BrushShape.CIRCLE

## 背景颜色。橡皮擦使用此颜色覆盖绘制（模拟擦除效果）。
var bg_color := Color.WHITE

## 绘图区域面板的引用。
@onready var drawing_area: Panel = $"../DrawingAreaBG"


## _process 每帧处理：检测鼠标位置和输入，执行绘制逻辑。
##
## 核心逻辑：
## 1. 检测鼠标是否在画布内
## 2. 鼠标左键按下时，根据画笔模式添加笔触数据
## 3. 铅笔/橡皮擦：鼠标移动超过1像素时连续绘制
## 4. 形状模式：鼠标释放时一次性添加形状
func _process(_delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()

	# 检查鼠标是否在画布区域内。
	var drawing_area_rect := Rect2(drawing_area.position, drawing_area.size)
	is_mouse_in_drawing_area = drawing_area_rect.has_point(mouse_pos)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# 如果是第一次按下左键，记录起始位置。
		if mouse_click_start_pos.is_equal_approx(Vector2.INF):
			mouse_click_start_pos = mouse_pos

		# 鼠标在画布内且移动超过1像素时，执行绘制。
		if check_if_mouse_is_inside_canvas():
			if mouse_pos.distance_to(last_mouse_pos) >= 1:
				# 铅笔或橡皮擦模式：连续绘制。
				if brush_mode == BrushMode.PENCIL or brush_mode == BrushMode.ERASER:
					# 如果尚未设置撤销点，记录当前列表大小作为撤销点。
					if undo_set == false:
						undo_set = true
						undo_element_list_num = brush_data_list.size()
					# 添加笔触数据。
					add_brush(mouse_pos, brush_mode)

	else:
		# 鼠标释放，允许下一次绘制设置新的撤销点。
		undo_set = false

		# 鼠标在画布内且为形状模式时，添加形状笔触。
		if check_if_mouse_is_inside_canvas():
			if brush_mode == BrushMode.CIRCLE_SHAPE or brush_mode == BrushMode.RECTANGLE_SHAPE:
				add_brush(mouse_pos, brush_mode)
				# 形状模式的撤销标记设为 UNDO_MODE_SHAPE。
				undo_element_list_num = UNDO_MODE_SHAPE
		# 重置鼠标点击起始位置。
		mouse_click_start_pos = Vector2.INF

	# 保存当前鼠标位置供下一帧使用。
	last_mouse_pos = mouse_pos


## 检查鼠标是否在画布内且点击起始位置也在画布内。
## 防止从画布外（如颜色选择器）点击后拖入画布时意外绘制。
##
## 返回: [bool] 鼠标点击起始位置和当前位置都在画布内则返回 true
func check_if_mouse_is_inside_canvas() -> bool:
	if mouse_click_start_pos != null:
		if Rect2(drawing_area.position, drawing_area.size).has_point(mouse_click_start_pos):
			if is_mouse_in_drawing_area:
				return true
	return false


## 撤销上一次笔触。
## 形状模式（UNDO_MODE_SHAPE）：直接移除最后一个笔触。
## 铅笔/橡皮擦模式：移除从撤销点到当前的所有笔触。
func undo_stroke() -> void:
	if undo_element_list_num == UNDO_NONE:
		return

	# 形状模式：移除最后一个笔触。
	if undo_element_list_num == UNDO_MODE_SHAPE:
		if brush_data_list.size() > 0:
			brush_data_list.remove_at(brush_data_list.size() - 1)

		undo_element_list_num = UNDO_NONE

	# 铅笔/橡皮擦模式：移除从撤销点到末尾的所有笔触。
	else:
		var elements_to_remove := brush_data_list.size() - undo_element_list_num
		for _elment_num in elements_to_remove:
			brush_data_list.pop_back()

		undo_element_list_num = UNDO_NONE

	queue_redraw()


## 添加笔触数据到列表。根据画笔模式计算并存储绘制所需的所有信息。
##
## 参数:
##   mouse_pos: 当前鼠标位置
##   type: 画笔模式（PENCIL/ERASER/CIRCLE_SHAPE/RECTANGLE_SHAPE）
##
## 对于矩形形状：计算左上角和右下角坐标
## 对于圆形形状：计算圆心和半径
func add_brush(mouse_pos: Vector2, type: BrushMode) -> void:
	var new_brush := {}

	# 填充基本画笔属性。
	new_brush.brush_type = type
	new_brush.brush_pos = mouse_pos
	new_brush.brush_shape = brush_shape
	new_brush.brush_size = brush_size
	new_brush.brush_color = brush_color

	# 矩形形状：计算左上角和右下角坐标。
	if type == BrushMode.RECTANGLE_SHAPE:
		var TL_pos := Vector2()
		var BR_pos := Vector2()

		# 计算左右边界。
		if mouse_pos.x < mouse_click_start_pos.x:
			TL_pos.x = mouse_pos.x
			BR_pos.x = mouse_click_start_pos.x
		else:
			TL_pos.x = mouse_click_start_pos.x
			BR_pos.x = mouse_pos.x

		# 计算上下边界。
		if mouse_pos.y < mouse_click_start_pos.y:
			TL_pos.y = mouse_pos.y
			BR_pos.y = mouse_click_start_pos.y
		else:
			TL_pos.y = mouse_click_start_pos.y
			BR_pos.y = mouse_pos.y

		new_brush.brush_pos = TL_pos
		new_brush.brush_shape_rect_pos_BR = BR_pos

	# 圆形形状：计算圆心和半径。
	if type == BrushMode.CIRCLE_SHAPE:
		var center_pos := Vector2((mouse_pos.x + mouse_click_start_pos.x) / 2, (mouse_pos.y + mouse_click_start_pos.y) / 2)
		new_brush.brush_pos = center_pos
		new_brush.brush_shape_circle_radius = center_pos.distance_to(Vector2(center_pos.x, mouse_pos.y))

	# 添加到列表并触发重绘。
	brush_data_list.append(new_brush)
	queue_redraw()


## _draw 绘制函数：遍历所有笔触数据并绘制到画布上。
##
## 根据 BrushMode 分四种情况绘制：
## - PENCIL：用画笔颜色绘制矩形或圆形点
## - ERASER：用背景色覆盖（模拟擦除）
## - RECTANGLE_SHAPE：绘制空心矩形
## - CIRCLE_SHAPE：绘制空心圆
func _draw() -> void:
	for brush in brush_data_list:
		match brush.brush_type:
			BrushMode.PENCIL:
				if brush.brush_shape == BrushShape.RECTANGLE:
					var rect := Rect2(brush.brush_pos - Vector2(brush.brush_size / 2, brush.brush_size / 2), Vector2(brush.brush_size, brush.brush_size))
					draw_rect(rect, brush.brush_color)
				elif brush.brush_shape == BrushShape.CIRCLE:
					draw_circle(brush.brush_pos, brush.brush_size / 2, brush.brush_color)
			BrushMode.ERASER:
				# 注意：这是一种简单的"擦除"方式，并非真正的像素擦除。
				# 但效果类似且实现简单。
				if brush.brush_shape == BrushShape.RECTANGLE:
					var rect := Rect2(brush.brush_pos - Vector2(brush.brush_size / 2, brush.brush_size / 2), Vector2(brush.brush_size, brush.brush_size))
					draw_rect(rect, bg_color)
				elif brush.brush_shape == BrushShape.CIRCLE:
					draw_circle(brush.brush_pos, brush.brush_size / 2, bg_color)
			BrushMode.RECTANGLE_SHAPE:
				var rect := Rect2(brush.brush_pos, brush.brush_shape_rect_pos_BR - brush.brush_pos)
				draw_rect(rect, brush.brush_color)
			BrushMode.CIRCLE_SHAPE:
				draw_circle(brush.brush_pos, brush.brush_shape_circle_radius, brush.brush_color)


## 保存画布为图片文件。
## 等待当前帧渲染完成后截取视口纹理，裁剪出画布区域，根据文件扩展名保存为 PNG/WEBP/JPG。
func save_picture(path: String) -> void:
	await RenderingServer.frame_post_draw

	var img := get_viewport().get_texture().get_image()
	# 裁剪出画布区域。
	var cropped_image := img.get_region(Rect2(drawing_area.position, drawing_area.size))

	# 根据文件扩展名选择保存格式。
	if path.to_lower().ends_with(".png"):
		cropped_image.save_png(path)
	elif path.to_lower().ends_with(".webp"):
		cropped_image.save_webp(path)
	elif path.to_lower().ends_with(".jpg") or path.to_lower().ends_with(".jpeg"):
		cropped_image.save_jpg(path, 1.0)
