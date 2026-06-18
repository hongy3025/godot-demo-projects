## 物理插值演示子弹 —— 使用缩放曲线实现淡出效果。
##
## 继承自 [RigidBody3D]，发射后第一帧禁用碰撞（防止与玩家碰撞），
## 然后根据缩放曲线逐渐缩小直至消失。
extends RigidBody3D

## 缩放曲线资源，定义子弹随时间变化的缩放值。
@export var scale_curve: Curve

## 碰撞是否已启用。
var _enabled: bool = false


## _ready 入口。初始禁用碰撞形状。
func _ready() -> void:
	$CollisionShape3D.disabled = true


## _physics_process 入口。启用碰撞并应用缩放曲线。
##
## 参数:
##   delta: 帧时间间隔（未使用）
##
## 核心逻辑：
## 1. 第一帧后启用碰撞，防止子弹刚发射时与玩家碰撞
## 2. 根据 Timer 剩余时间采样缩放曲线，实现淡出效果
func _physics_process(_delta: float) -> void:
	# 第一帧后启用碰撞。
	if !_enabled:
		$CollisionShape3D.disabled = false
		_enabled = true

	# 根据缩放曲线应用外观缩放。
	var time_left_ratio: float = 1.0 - $Timer.time_left / $Timer.wait_time
	var scale_sampled := scale_curve.sample_baked(time_left_ratio)
	$Scaler.scale = Vector3.ONE * scale_sampled


## 计时器超时回调。销毁子弹。
func _on_timer_timeout() -> void:
	queue_free()
