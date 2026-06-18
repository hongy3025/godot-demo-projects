## 布娃娃角色 —— 具有物理模拟和碰撞音效的人体模型。
##
## 继承自 [Node3D]，启动时激活物理骨骼模拟，根据骨盆速度变化播放碰撞音效。
extends Node3D

## 触发小声碰撞音效的速度阈值。
const IMPACT_SOUND_SPEED_SMALL = 0.3
## 触发大声碰撞音效的速度阈值。
const IMPACT_SOUND_SPEED_BIG = 1.0

## 在第一物理帧应用的速度。
@export var initial_velocity: Vector3

## 是否已应用初始速度。
var has_applied_initial_velocity: bool = false
## 上一帧的骨盆速度，用于检测速度突变以播放碰撞音效。
var previous_pelvis_speed: float = 0.0

## 骨盆物理骨骼节点引用（靠近角色模型质心）。
@onready var pelvis: PhysicalBone3D = $"root/root_001/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone pelvis"


## _ready 入口。启动物理骨骼模拟并应用初始速度。
func _ready() -> void:
	$root/root_001/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	if not initial_velocity.is_zero_approx():
		for physical_bone in $root/root_001/Skeleton3D/PhysicalBoneSimulator3D.get_children():
			# 为所有骨骼施加冲量，使布娃娃生成时具有初始运动。
			physical_bone.apply_central_impulse(initial_velocity)


## _physics_process 入口。检测速度变化并播放碰撞音效。
##
## 参数:
##   delta: 帧时间间隔（未使用）
##
## 核心逻辑：
## 1. 计算骨盆速度变化量（除以 time_scale 以消除时间缩放的影响）
## 2. 根据速度变化量大小播放不同音效
func _physics_process(_delta: float) -> void:
	var pelvis_speed: float = pelvis.linear_velocity.length()
	# 除以 time_scale 确保速度阈值不受时间缩放影响。
	var impact_speed := (previous_pelvis_speed - pelvis_speed) / Engine.time_scale
	if impact_speed > IMPACT_SOUND_SPEED_BIG:
		$ImpactSoundBig.play()
	elif impact_speed > IMPACT_SOUND_SPEED_SMALL:
		$ImpactSoundSmall.play()

	previous_pelvis_speed = pelvis_speed
