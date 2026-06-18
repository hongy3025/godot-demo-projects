## 子弹管理器 —— 使用 PhysicsServer2D 实现的高性能子弹系统。
##
## 本示例演示如何在不使用场景节点的情况下，用纯代码控制大量 2D 对象的逻辑和碰撞。
## 相比实例化节点的方式，此技术效率更高，但需要更多的编程工作且不直观。
## 所有子弹在 `bullets.gd` 中统一管理，而非每个子弹独立挂载脚本。
extends Node2D

## 同时存在的子弹总数。
const BULLET_COUNT = 500

## 子弹最小移动速度（像素/秒）。
const SPEED_MIN = 20

## 子弹最大移动速度（像素/秒）。
const SPEED_MAX = 80

## 子弹纹理资源，预加载避免运行时 I/O。
const bullet_image := preload("res://bullet.png")

## 所有子弹实例的数组。
var bullets := []

## 共享的圆形碰撞形状 RID，所有子弹复用同一个形状以节省资源。
var shape := RID()


## 子弹数据结构体，存储位置、速度和物理体 RID。
## 使用 RID 而非节点引用，在大规模对象（数千个以上）时性能显著更高。
class Bullet:
	## 子弹在 2D 空间中的位置。
	var position := Vector2()
	## 子弹移动速度（像素/秒）。
	var speed := 1.0
	## 物理体 RID，通过 PhysicsServer2D 操作，比节点方式更快。
	var body := RID()


## _ready 入口：创建碰撞形状并初始化所有子弹。
func _ready() -> void:
	# 创建圆形碰撞形状，半径为 8 像素
	shape = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape, 8)

	for _i in BULLET_COUNT:
		var bullet := Bullet.new()
		# 为每颗子弹分配随机速度
		bullet.speed = randf_range(SPEED_MIN, SPEED_MAX)
		bullet.body = PhysicsServer2D.body_create()

		# 将子弹物理体注册到当前世界的物理空间
		PhysicsServer2D.body_set_space(bullet.body, get_world_2d().get_space())
		PhysicsServer2D.body_add_shape(bullet.body, shape)
		# 禁止子弹之间相互碰撞，提升性能
		PhysicsServer2D.body_set_collision_mask(bullet.body, 0)

		# 在视口范围内随机生成位置，并向右偏移一个屏幕宽度
		# 使子弹从右侧外进入画面，产生渐入效果
		bullet.position = Vector2(
				randf_range(0, get_viewport_rect().size.x) + get_viewport_rect().size.x,
				randf_range(0, get_viewport_rect().size.y)
			)
		var transform2d := Transform2D()
		transform2d.origin = bullet.position
		PhysicsServer2D.body_set_state(bullet.body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform2d)

		bullets.push_back(bullet)


## _process 入口：每帧请求重绘，由 _draw 统一渲染所有子弹。
func _process(_delta: float) -> void:
	queue_redraw()


## _physics_process 入口：以固定时间步长更新所有子弹的位置。
## 子弹向左移动，超出左边界后循环到右侧重新出现。
func _physics_process(delta: float) -> void:
	var transform2d := Transform2D()
	var offset := get_viewport_rect().size.x + 16
	for bullet: Bullet in bullets:
		bullet.position.x -= bullet.speed * delta

		# 超出左边界（x < -16）时，循环到右侧重新出现
		if bullet.position.x < -16:
			bullet.position.x = offset

		# 将更新后的位置同步到 PhysicsServer2D
		transform2d.origin = bullet.position
		PhysicsServer2D.body_set_state(bullet.body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform2d)


## _draw 入口：一次性绘制所有子弹的纹理。
## 使用统一绘制而非每个子弹独立绘制，大幅减少绘制调用次数。
func _draw() -> void:
	var offset := -bullet_image.get_size() * 0.5
	for bullet: Bullet in bullets:
		draw_texture(bullet_image, bullet.position + offset)


## _exit_tree 入口：清理所有物理资源，避免退出时控制台报错。
func _exit_tree() -> void:
	for bullet: Bullet in bullets:
		PhysicsServer2D.free_rid(bullet.body)

	PhysicsServer2D.free_rid(shape)
	bullets.clear()
