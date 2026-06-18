## 2.5D 阴影投射节点 —— 向地面发射射线检测碰撞，定位阴影位置。
##
## 继承自 [ShapeCast3D]，作为 Shadow25D 的子节点存在。
## Shadow25D 应放置在目标对象的下方（场景树中的前一个兄弟节点）。
## 每帧向下发射球形射线，检测碰撞点后将阴影节点定位到地面。
##
## 场景树结构要求:
##   TargetNode (Node25D)
##     ├── TargetMath (Node3D)          ← 目标对象的 3D 节点
##     └── ...
##   Shadow25D (Node25D)                ← 阴影根节点（前一个兄弟）
##     ├── ShadowMath25D (ShapeCast3D)  ← 本脚本
##     └── ShadowSprite (Sprite2D)      ← 阴影精灵
@tool
@icon("res://addons/node25d/icons/shadow_math_25d_icon.png")
class_name ShadowMath25D
extends ShapeCast3D


# 阴影根节点 (Node25D 类型)
var _shadow_root: Node25D
# 目标对象的 3D 物理节点
var _target_math: Node3D


## _ready 入口，获取阴影根节点并定位目标对象的 3D 节点。
## 通过兄弟节点索引定位目标: 阴影节点应位于目标节点的下一个兄弟位置。
func _ready() -> void:
	_shadow_root = get_parent()

	# 通过兄弟节点索引定位目标: 阴影节点应位于目标节点的下一个兄弟位置
	var index := _shadow_root.get_index()
	if index > 0:  # 否则阴影位置无效
		var sibling_25d: Node = _shadow_root.get_parent().get_child(index - 1)
		if sibling_25d.get_child_count() > 0:
			var target = sibling_25d.get_child(0)
			if target is Node3D:
				_target_math = target
				return

	push_error("Shadow is not in the correct place, expected a previous sibling node with a 3D first child.")


## _physics_process 入口，每物理帧执行阴影碰撞检测。
## 将 ShapeCast 定位到目标对象的 3D 位置，向下发射射线检测地面碰撞点。
## 有碰撞则显示阴影并定位到碰撞点，无碰撞则隐藏阴影（悬空）。
func _physics_process(_delta: float) -> void:
	if _target_math == null:
		if _shadow_root != null:
			_shadow_root.visible = false
		return  # 阴影位置无效，或正在查看 Shadow25D 场景本身

	# 将 ShapeCast 定位到目标对象的 3D 位置并执行碰撞检测
	position = _target_math.position
	force_shapecast_update()

	if is_colliding():
		# 有碰撞: 将阴影定位到碰撞点（地面），显示阴影
		global_position = get_collision_point(0)
		_shadow_root.visible = true
	else:
		# 无碰撞: 悬空，隐藏阴影
		_shadow_root.visible = false
