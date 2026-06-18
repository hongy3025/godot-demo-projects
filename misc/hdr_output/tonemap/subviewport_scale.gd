## 子视口缩放适配器 —— 根据主视口大小自动调整子视口分辨率。
##
## 继承自 [Node]，监听主视口大小变化事件，按比例调整 SubViewport 的分辨率，
## 确保子视口在不同窗口大小下保持清晰。
extends Node

## 子视口初始大小
@export var sub_viewport_initial_size: Vector2
## 主视口初始大小
@export var main_viewport_initial_size: Vector2
@onready var sub_viewport: SubViewport = $MySubViewport
@onready var viewport_sprite: Sprite2D = $ViewportSprite


## _ready 入口，连接主视口大小变化信号。
func _ready() -> void:
	get_viewport().size_changed.connect(_root_viewport_size_changed)
	_root_viewport_size_changed()


## 主视口大小变化回调，按比例调整子视口分辨率。
func _root_viewport_size_changed() -> void:
	# 根据窗口大小自动调整子视口分辨率
	# 确保子视口在大于默认值的窗口大小下保持清晰
	sub_viewport.size.x = sub_viewport_initial_size.x * (get_viewport().size.y / main_viewport_initial_size.y)
	sub_viewport.size.y = sub_viewport_initial_size.y * (get_viewport().size.y / main_viewport_initial_size.y)
	viewport_sprite.scale.x = sub_viewport_initial_size.x / sub_viewport.size.x
	viewport_sprite.scale.y = sub_viewport_initial_size.y / sub_viewport.size.y
