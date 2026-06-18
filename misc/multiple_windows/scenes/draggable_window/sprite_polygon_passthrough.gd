## 精灵穿透多边形生成器 —— 根据精灵的透明度生成鼠标穿透多边形。
##
## 继承自 [Node]，从 Sprite2D 的纹理中提取不透明像素区域，
## 生成多边形数组后应用到窗口的 mouse_passthrough_polygon 属性。
extends Node


## 目标精灵引用
@export var sprite: Sprite2D


## 生成穿透多边形并应用到窗口。
func generate_polygon():
	# 从精灵创建位图
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(sprite.texture.get_image())
	# 计算精灵单元格尺寸（支持精灵表动画）
	var cell_size_x := float(bitmap.get_size().x) / sprite.hframes
	var cell_size_y := float(bitmap.get_size().y) / sprite.vframes
	var cell_rect: Rect2 = Rect2(cell_size_x * sprite.frame_coords.x, cell_size_y * sprite.frame_coords.y, cell_size_x, cell_size_y)
	# 扩展位图确保所有像素被捕获
	bitmap.grow_mask(1, cell_rect)
	# 从位图生成多边形数组
	var bitmap_polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(cell_rect, 1.0)
	var polygon = PackedVector2Array()
	# 偏移量，使多边形位置与精灵在窗口中的位置对齐
	var offset: Vector2 = sprite.position + sprite.offset
	if sprite.centered:
		offset -= Vector2(cell_size_x, cell_size_y) / 2

	# 使用第一个点连接多个多边形为一个大的多边形
	var first_point: Vector2 = bitmap_polygons[0][0]
	# 将所有多边形合并为窗口可用的单个多边形
	for bitmap_polygon: PackedVector2Array in bitmap_polygons:
		for point: Vector2 in bitmap_polygon:
			polygon.append(point + offset)

		polygon.append(first_point)
		polygon.append(first_point)

	# 将穿透遮罩应用到窗口
	get_window().mouse_passthrough_polygon = polygon
