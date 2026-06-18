## 3D 路径点标记 —— 将 3D 空间中的目标位置投影到 2D 屏幕上的 UI 指示器。
##
## 继承自 [Control]，作为父节点（必须是 [Node3D]）的屏幕空间指示器。
## 支持"粘性"模式：当目标移出屏幕时，标记会吸附到屏幕边缘并显示方向箭头。
## 当摄像机靠近目标时，标记会逐渐淡出。
extends Control


## 屏幕边缘留白像素数，防止标记紧贴屏幕角落。
const MARGIN = 8

## 路径点的显示文本。
## 通过 setter 在文本改变时自动更新 Label 节点的显示内容。
@export var text: String = "Waypoint":
	set(value):
		text = value
		# Label 的文本只能在节点就绪后设置。
		if is_inside_tree():
			label.text = value

## 如果为 `true`，路径点移出屏幕时会吸附到视口边缘。
@export var sticky: bool = true

## 当前活动的 3D 摄像机引用，用于计算投影位置。
@onready var camera := get_viewport().get_camera_3d()
## 父节点引用（必须是 Node3D），用于获取目标的世界坐标。
@onready var parent := get_parent()
## 显示路径点文本的 Label 节点。
@onready var label: Label = $Label
## 显示路径点图标的 TextureRect 节点。
@onready var marker: TextureRect = $Marker


## _ready 入口。初始化文本并断言父节点是 Node3D 类型。
func _ready() -> void:
	self.text = text
	assert(parent is Node3D, "路径点的父节点必须继承自 Node3D。")


## _process 入口。每帧更新路径点的屏幕位置和可见性。
##
## 核心逻辑：
## 1. 如果当前摄像机不是活动摄像机，重新获取活动摄像机
## 2. 计算目标是否在摄像机后方
## 3. 根据距离淡出标记
## 4. 将 3D 坐标投影到屏幕坐标
## 5. 如果是粘性模式，将位置限制在屏幕边缘并显示方向箭头
func _process(_delta: float) -> void:
	if not camera.current:
		# 如果缓存的摄像机不是当前活动的，重新获取当前摄像机。
		camera = get_viewport().get_camera_3d()

	var parent_position: Vector3 = parent.global_transform.origin
	var camera_transform := camera.global_transform
	var camera_position := camera_transform.origin

	# 判断目标是否在摄像机后方。
	# 不使用 "camera.is_position_behind(parent_position)" 是因为该方法会考虑近裁剪面。
	var is_behind := camera_transform.basis.z.dot(parent_position - camera_position) > 0

	# 根据摄像机与目标的距离淡出路径点。
	var distance := camera_position.distance_to(parent_position)
	modulate.a = clamp(remap(distance, 0, 2, 0, 1), 0, 1 )

	var unprojected_position := camera.unproject_position(parent_position)
	# 当拉伸模式为 `2d` 时，`get_size_override()` 返回有效尺寸。
	# 否则直接使用视口尺寸。
	var viewport_base_size: Vector2i = (
			get_viewport().content_scale_size if get_viewport().content_scale_size > Vector2i(0, 0)
			else get_viewport().size
		)

	if not sticky:
		# 非粘性模式：目标移出屏幕时直接隐藏，不做边缘吸附。
		position = unprojected_position
		visible = not is_behind
		return

	# 粘性模式：分别处理 X 轴和 Y 轴。
	# X 轴：投影位置有用，但如果目标在后方则强制吸附到侧边。
	if is_behind:
		if unprojected_position.x < viewport_base_size.x / 2:
			unprojected_position.x = viewport_base_size.x - MARGIN
		else:
			unprojected_position.x = MARGIN

	# Y 轴：投影位置在后方时无用，因为不需要提示用户上下看。
	# 改用摄像机 X 轴欧拉角差值与 FOV 的比值来估算 Y 坐标。
	if is_behind or unprojected_position.x < MARGIN or \
			unprojected_position.x > viewport_base_size.x - MARGIN:
		var look := camera_transform.looking_at(parent_position, Vector3.UP)
		var diff := angle_difference(look.basis.get_euler().x, camera_transform.basis.get_euler().x)
		unprojected_position.y = viewport_base_size.y * (0.5 + (diff / deg_to_rad(camera.fov)))

	# 将位置限制在屏幕边缘范围内。
	position = Vector2(
			clamp(unprojected_position.x, MARGIN, viewport_base_size.x - MARGIN),
			clamp(unprojected_position.y, MARGIN, viewport_base_size.y - MARGIN)
		)

	label.visible = true
	rotation = 0
	# 当路径点位于屏幕角落时，显示对角线方向箭头。
	var overflow := 0

	if position.x <= MARGIN:
		# 左侧溢出：箭头指向左。
		overflow = int(-TAU / 8.0)
		label.visible = false
		rotation = TAU / 4.0
	elif position.x >= viewport_base_size.x - MARGIN:
		# 右侧溢出：箭头指向右。
		overflow = int(TAU / 8.0)
		label.visible = false
		rotation = TAU * 3.0 / 4.0

	if position.y <= MARGIN:
		# 顶部溢出：箭头指向上。
		label.visible = false
		rotation = TAU / 2.0 + overflow
	elif position.y >= viewport_base_size.y - MARGIN:
		# 底部溢出：箭头指向下。
		label.visible = false
		rotation = -overflow
