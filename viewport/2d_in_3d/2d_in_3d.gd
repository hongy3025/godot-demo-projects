extends Node3D
# 继承自 Node3D 类，使该脚本附加的节点具有 3D 空间中的变换能力（位置、旋转、缩放）。

## Camera idle scale effect intensity.
# 文档注释（双 #）：说明下方常量的用途——相机动画摇摆效果的强度系数。
const CAMERA_IDLE_SCALE = 0.005
# 定义一个常量（不可修改），数值为 0.005，用于控制后续相机动画的摇摆幅度。

var counter := 0.0
# 声明一个变量 counter 并初始化为 0.0，它将作为时间计数器，用于驱动正弦/余弦动画。
@onready var camera_base_rotation: Vector3 = $Camera3D.rotation
# @onready 表示在节点完全进入场景树后执行此行赋值。
# 将场景中名为 Camera3D 的子节点的初始旋转值保存到 camera_base_rotation 变量中，类型为 Vector3（三维向量）。
# 这样后续动画可以基于这个初始角度进行偏移，而不是覆盖为绝对值。

func _ready() -> void:
	# _ready 是 Godot 的内置虚函数，当节点及其子节点都进入场景树后自动调用一次。
	# -> void 表示该函数不返回任何值。
	# Clear the viewport.
	# 英文注释：清除视口。
	var viewport: SubViewport = $SubViewport
	# 通过 $ 语法（get_node 的简写）获取名为 SubViewport 的子节点，并将其赋值给 viewport 变量。
	# SubViewport 是一个子视口，可以独立渲染 2D 内容，常用于将 2D 界面显示在 3D 物体上。
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	# 设置子视口的渲染目标清除模式为 CLEAR_MODE_ONCE，表示只在开始时清除一次，之后保留上一帧内容。

	# Retrieve the texture and set it to the viewport quad.
	# 英文注释：获取子视口渲染出的纹理，并将其设置到用于显示的 3D 四边形（quad）上。
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	# 获取 ViewportQuad 节点（一个 3D 网格/四边形）的 material_override（材质覆盖）。
	# 将子视口当前渲染的纹理（viewport.get_texture()）赋给材质的反照率（albedo）纹理槽位。
	# 这样 3D 世界中的这个四边形表面就会实时显示 SubViewport 里渲染的 2D 内容。


func _process(delta: float) -> void:
	# _process 是 Godot 的内置虚函数，每帧都会被调用一次。
	# delta 参数表示上一帧到当前帧所经过的时间（秒），用于保证动画速度不受帧率影响。
	# Animate the camera with an "idle" animation.
	# 英文注释：用“待机动画”让相机产生轻微的摇摆效果。
	counter += delta
	# 将 counter 时间计数器累加上本帧的 delta 时间，使其随游戏时间线性增长。
	$Camera3D.rotation.x = camera_base_rotation.y + cos(counter) * CAMERA_IDLE_SCALE
	# 设置 Camera3D 的 X 轴旋转：以初始 Y 轴旋转值为基准，叠加上 cos(counter) 乘以强度系数。
	# cos 函数产生 -1 到 1 的周期性波动，使相机在 X 轴方向上来回轻微摇摆。
	$Camera3D.rotation.y = camera_base_rotation.y + sin(counter) * CAMERA_IDLE_SCALE
	# 设置 Camera3D 的 Y 轴旋转：同样以初始 Y 轴旋转值为基准，叠加上 sin(counter) 乘以强度系数。
	# sin 与 cos 相位差 90 度，配合起来让相机产生更自然的空间摇摆（idle 感）。
	$Camera3D.rotation.z = camera_base_rotation.y + sin(counter) * CAMERA_IDLE_SCALE
	# 设置 Camera3D 的 Z 轴旋转：也叠加 sin(counter) 的波动，使相机在 Z 轴（翻滚方向）也有轻微摆动。
	# 最终效果是相机仿佛“呼吸”般轻微晃动，增加场景的生动感。
