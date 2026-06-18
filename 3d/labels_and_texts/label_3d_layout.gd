## 3D 标签布局演示 —— 模拟 RPG 角色头顶的血条和名称标签。
##
## 继承自 [Node3D]，通过调整 Label3D 的 `offset` 属性实现布局效果。
## 注意：要实现正确的公告板（billboard）行为，必须调整 Label3D 的 `offset` 属性而非 `position` 属性。
extends Node3D

## 当前生命值（0~100），通过 setter 更新 UI。
var health := 0: set = set_health
## 计时器计数器，用于动画生命值变化。
var counter := 0.0

# 名称和生命值百分比之间的间距（像素）。
const HEALTH_MARGIN = 25

# 血条宽度（字符数）。
# 更高的值精度更高，但性能更低（需要渲染更多字符）。
const BAR_WIDTH = 100

## _ready 入口。初始化输入框文本。
func _ready() -> void:
	$LineEdit.text = $Name.text


## _process 入口。使用正弦波动画模拟生命值变化。
##
## 参数:
##   delta: 帧时间间隔
func _process(delta: float) -> void:
	counter += delta
	health = roundi(50 + sin(counter * 0.5) * 50)


## 输入框文本变化回调。更新名称标签并自动调整字号。
##
## 参数:
##   new_text: 新的名称文本
##
## 核心逻辑：从 32 号字体开始递减，直到文本宽度不超过标签宽度。
func _on_line_edit_text_changed(new_text: String) -> void:
	$Name.text = new_text

	# 调整名称字号以适配允许的宽度。
	$Name.font_size = 32
	while $Name.font.get_string_size($Name.text, $Name.horizontal_alignment, -1, $Name.font_size).x > $Name.width:
		$Name.font_size -= 1


## 设置生命值并更新 UI 显示。
##
## 参数:
##   p_health: 生命值（0~100）
##
## 更新内容：
## 1. 生命值百分比文本和颜色（低血量变红）
## 2. 前景血条和背景血条的文本和颜色
## 3. 血条使用 `|` 字符构建，通过 FontVariation 缩小字符间距
func set_health(p_health: int) -> void:
	health = p_health

	$Health.text = "%d%%" % round(health)
	if health <= 30:
		# 低血量警告颜色。
		$Health.modulate = Color(1, 0.2, 0.1)
		$Health.outline_modulate = Color(0.2, 0.1, 0.0)
		$HealthBarForeground.modulate = Color(1, 0.2, 0.1)
		$HealthBarForeground.outline_modulate = Color(0.2, 0.1, 0.0)
		$HealthBarBackground.outline_modulate = Color(0.2, 0.1, 0.0)
		$HealthBarBackground.modulate = Color(0.2, 0.1, 0.0)
	else:
		$Health.modulate = Color(0.8, 1, 0.4)
		$Health.outline_modulate = Color(0.15, 0.2, 0.15)
		$HealthBarForeground.modulate = Color(0.8, 1, 0.4)
		$HealthBarForeground.outline_modulate = Color(0.15, 0.2, 0.15)
		$HealthBarBackground.outline_modulate = Color(0.15, 0.2, 0.15)
		$HealthBarBackground.modulate = Color(0.15, 0.2, 0.15)

	# 使用 `|` 字符构建血条，通过 HealthBarForeground 和 HealthBarBackground 节点上的
	# 自定义 FontVariation 将字符间距缩小到几乎为零。
	var bar_text: String = ""
	var bar_text_bg: String = ""
	for i in roundi((health / 100.0) * BAR_WIDTH):
		bar_text += "|"
	for i in BAR_WIDTH:
		bar_text_bg += "|"

	$HealthBarForeground.text = str(bar_text)
	$HealthBarBackground.text = str(bar_text_bg)
