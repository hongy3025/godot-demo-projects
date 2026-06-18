## 炸弹人玩家逻辑 —— 处理玩家移动、炸弹放置、动画和网络同步。
##
## 继承自 [CharacterBody2D]，作为游戏中的玩家角色。
## 采用"服务器权威 + 客户端预测"的网络模型：
## - 服务器更新同步位置并管理炸弹冷却
## - 客户端预测物理运动以获得流畅体验
## - 所有对等端各自运行动画
extends CharacterBody2D

## 玩家移动速度（像素/秒）。
const MOTION_SPEED = 90.0

## 炸弹放置冷却时间（秒）。
const BOMB_RATE = 0.5

## 同步位置，由服务器更新、客户端读取。
@export var synced_position := Vector2()

## 玩家是否处于眩晕状态。
@export var stunned: bool = false

## 上次放置炸弹的时间戳，用于冷却计算。
var last_bomb_time := BOMB_RATE
## 当前播放的动画名称。
var current_anim: String = ""

## 玩家输入控制器节点引用。
@onready var inputs: Node = $Inputs


## _ready 入口：初始化位置和网络权限。
##
## 如果玩家名称是有效整数（即对等端 ID），
## 将 InputsSync 的网络权限交给对应的对等端。
func _ready() -> void:
	stunned = false
	position = synced_position
	if str(name).is_valid_int():
		$"Inputs/InputsSync".set_multiplayer_authority(str(name).to_int())


## _physics_process 每物理帧处理：输入、移动、炸弹冷却和动画。
##
## 核心逻辑：
## 1. 玩家所属的客户端更新输入状态
## 2. 服务器更新同步位置和管理炸弹冷却
## 3. 客户端读取同步位置进行插值
## 4. 所有对等端各自运行动画
func _physics_process(delta: float) -> void:
	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
		# 该玩家所属的客户端更新控制状态，并通知所有人。
		inputs.update()

	if multiplayer.multiplayer_peer == null or is_multiplayer_authority():
		# 服务器更新位置，将通知给客户端。
		synced_position = position
		# 增加炸弹冷却计时，如果玩家请求放置炸弹且冷却已过，则生成炸弹。
		last_bomb_time += delta
		if not stunned and is_multiplayer_authority() and inputs.bombing and last_bomb_time >= BOMB_RATE:
			last_bomb_time = 0.0
			$"../../BombSpawner".spawn([position, str(name).to_int()])
	else:
		# 客户端更新位置到服务器同步的最新值。
		position = synced_position

	if not stunned:
		# 所有对等端都运行物理模拟（客户端预测下一帧位置）。
		velocity = inputs.motion * MOTION_SPEED
		move_and_slide()

	# 根据玩家输入更新动画状态。
	var new_anim := &"standing"

	if inputs.motion.y < 0:
		new_anim = &"walk_up"
	elif inputs.motion.y > 0:
		new_anim = &"walk_down"
	elif inputs.motion.x < 0:
		new_anim = &"walk_left"
	elif inputs.motion.x > 0:
		new_anim = &"walk_right"

	if stunned:
		new_anim = &"stunned"

	if new_anim != current_anim:
		current_anim = new_anim
		$anim.play(current_anim)


## 设置玩家名称和颜色。在所有对等端本地调用。
## 参数 value: 玩家名称字符串。
@rpc("call_local")
func set_player_name(value: String) -> void:
	$label.text = value
	# 根据玩家名称分配随机颜色。
	$label.modulate = gamestate.get_player_color(value)
	$sprite.modulate = Color(0.5, 0.5, 0.5) + gamestate.get_player_color(value)


## 玩家被炸毁处理。在所有对等端本地调用。
## 如果已经眩晕则忽略。
## 参数 _by_who: 放置炸弹的玩家 ID。
@rpc("call_local")
func exploded(_by_who: int) -> void:
	if stunned:
		return

	stunned = true
	$anim.play(&"stunned")
