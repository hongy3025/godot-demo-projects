## 自定义节点 "Heart" 的脚本。
## 继承自 [Node2D]，在画布上绘制一个心形纹理。
## 通过重写 _draw 方法实现自定义绘制，通过 _get_item_rect 提供正确的包围盒。
@tool
extends Node2D


## 心形纹理的预加载常量。
## preload 在编译时加载资源，比运行时加载更高效。
const HEART_TEXTURE := preload("res://addons/custom_node/heart.png")


## 绘制回调。Godot 在需要重绘时自动调用。
## 在心形纹理的中心点绘制纹理，使纹理居中。
func _draw() -> void:
	# 将纹理绘制在 (-纹理尺寸/2) 位置，实现中心对齐
	draw_texture(HEART_TEXTURE, -HEART_TEXTURE.get_size() / 2)


## 返回节点的包围盒（用于编辑器选择框和碰撞检测）。
## 返回以节点中心为原点、纹理尺寸为大小的矩形区域。
func _get_item_rect() -> Rect2:
	return Rect2(-HEART_TEXTURE.get_size() / 2, HEART_TEXTURE.get_size())
