## 网格行走者 —— 可在网格上移动并播放动画的棋子基类。
## 继承自 Pawn，提供网格移动的动画化实现（通过 Tween 插值移动）。
class_name Walker
extends Pawn

## 战斗场景的 PackedScene，用于进入战斗时实例化。
@export var combat_actor: PackedScene
## 姿态动画的 SpriteFrames 资源。
@export var pose_anims: SpriteFrames

## 是否已输掉战斗。
var lost: bool = false
## 网格的单个格子大小（像素）。
var grid_size: float

## 父节点即 Grid 网格。
@onready var grid : Grid = get_parent()
## AnimationTree 中的状态机播放控制器。
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree.get(&"parameters/playback")
## 行走动画的时长，用于同步 Tween 移动时间。
@onready var walk_animation_time: float = $AnimationPlayer.get_animation(&"walk").length
## 姿态精灵节点（Pivot 下的子节点）。
@onready var pose := $Pivot/Slime


## 初始化：设置姿态精灵帧、默认朝向和网格大小。
func _ready() -> void:
	pose.sprite_frames = pose_anims
	update_look_direction(Vector2.RIGHT)
	grid_size = grid.tile_set.tile_size.x


## 更新角色的朝向。
## 参数 direction: 朝向的方向向量，用于计算旋转角度。
func update_look_direction(direction: Vector2) -> void:
	$Pivot/FacingDirection.rotation = direction.angle()


## 平滑移动到目标网格位置。
## 使用 Tween 插值 Pivot 的偏移来实现平滑行走动画。
## 参数 target_position: 目标位置的全局坐标。
func move_to(target_position: Vector2) -> void:
	set_process(false)
	var move_direction := (target_position - position).normalized()
	pose.play(&"idle")
	animation_playback.start(&"walk")

	# 创建 Tween 实现平滑移动，时长与行走动画同步
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	var end: Vector2 = $Pivot.position + move_direction * grid_size
	tween.tween_property($Pivot, ^"position", end, walk_animation_time)

	await tween.finished
	# 移动完成后重置 Pivot 偏移，更新实际位置
	$Pivot.position = Vector2.ZERO
	position = target_position
	animation_playback.start(&"idle")
	pose.play(&"idle")

	set_process(true)


## 播放碰撞动画（遇到障碍物时）。
func bump() -> void:
	set_process(false)
	pose.play(&"bump")
	animation_playback.start(&"bump")
	await $AnimationTree.animation_finished
	animation_playback.start(&"idle")
	pose.play(&"idle")
	set_process(true)
