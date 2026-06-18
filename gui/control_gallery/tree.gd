## Tree 控件演示 —— 展示 Godot 的 Tree（树形列表）控件用法。
## 标记为 @tool 可在编辑器中运行。
## 演示创建树形层级结构、设置文本、添加按钮等基本操作。
@tool
extends Tree


## _ready 入口：创建树形层级结构并设置示例数据。
func _ready() -> void:
	# 创建根 TreeItem
	var root: TreeItem = create_item()
	root.set_text(0, "Tree - Root TreeItem")
	# 加载图标并缩放到 16x16
	var image := preload("res://icon.webp").get_image()
	image.resize(16, 16)
	# 添加可用按钮和禁用按钮
	root.add_button(0, ImageTexture.create_from_image(image), -1, false, "Example TreeItem button.")
	root.add_button(0, ImageTexture.create_from_image(image), -1, true, "Example disabled TreeItem button.")

	# 创建子节点
	var child1: TreeItem = create_item(root)
	child1.set_text(0, "Tree - TreeItem 1")
	var child2: TreeItem = create_item(root)
	child2.set_text(0, "Tree - TreeItem 2")
	# 创建孙节点
	var subchild1: TreeItem = create_item(child1)
	subchild1.set_text(0, "Tree - TreeItem 1 Child")
