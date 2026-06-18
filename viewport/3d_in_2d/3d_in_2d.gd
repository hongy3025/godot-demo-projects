## 3D 嵌入 2D 演示 —— 将 3D 场景渲染到 SubViewport 并显示在 2D 精灵上。
##
## 继承自 [Node2D]，管理 SubViewport 的分辨率自适应。
## 当窗口大小变化时，调整 SubViewport 的大小以匹配窗口高度，
## 同时缩放 Sprite2D 以保持显示尺寸不变，从而避免画质损失。
extends Node2D

## 承载 3D 场景的子视口。
@onready var viewport: SubViewport = $SubViewport
## 子视口的初始尺寸，用于计算缩放比例。
@onready var viewport_initial_size: Vector2i = viewport.size
## 显示子视口纹理的 2D 精灵。
@onready var viewport_sprite: Sprite2D = $ViewportSprite


## 初始化：播放 2D 动画，连接窗口大小变化信号。
func _ready() -> void:
	$AnimatedSprite2D.play()
	get_viewport().size_changed.connect(_root_viewport_size_changed)


## 响应根视口大小变化（窗口缩放），调整 SubViewport 分辨率以保持画质。
##
## 核心逻辑：
##   当窗口变高时，SubViewport 的分辨率也随之增加，
##   同时 Sprite2D 的缩放比例相应减小，保证显示尺寸不变。
##   这样可以在高分辨率显示器上获得更清晰的 3D 渲染效果。
func _root_viewport_size_changed() -> void:
	viewport.size = Vector2.ONE * get_viewport().size.y
	viewport_sprite.scale = Vector2.ONE * viewport_initial_size.y / get_viewport().size.y
