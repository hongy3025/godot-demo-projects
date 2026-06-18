## 手柄映射数据类 —— 表示单个按键或摇杆的映射信息。
##
## 继承自 [RefCounted]，存储映射类型（按键/摇杆）、索引、轴范围和反转标志。
## 提供 SDL2 格式的序列化和人类可读的字符串表示。
class_name JoyMapping
extends RefCounted

## 映射类型枚举
enum Type {
	NONE,    # 未映射
	BTN,     # 按键
	AXIS,    # 摇杆/扳机
}

## 轴范围枚举
enum Axis {
	FULL,        # 全轴（正负方向）
	HALF_PLUS,   # 正半轴
	HALF_MINUS,  # 负半轴
}

## 平台名称映射表（SDL2 格式 -> Godot 格式）
const PLATFORMS = {
	# 来自 gamecontrollerdb
	"Windows": "Windows",
	"OSX": "Mac OS X",
	"X11": "Linux",
	"Android": "Android",
	"iOS": "iOS",
	# Godot 自定义
	"HTML5": "Javascript",
	"UWP": "UWP",
	# 4.x 兼容
	"Linux": "Linux",
	"FreeBSD": "Linux",
	"NetBSD": "Linux",
	"BSD": "Linux",
	"macOS": "Mac OS X",
}

## 标准手柄按键/摇杆索引映射表
const BASE = {
	# 按键
	"a": JOY_BUTTON_A,
	"b": JOY_BUTTON_B,
	"y": JOY_BUTTON_Y,
	"x": JOY_BUTTON_X,
	"start": JOY_BUTTON_START,
	"back": JOY_BUTTON_BACK,
	"leftstick": JOY_BUTTON_LEFT_STICK,
	"rightstick": JOY_BUTTON_RIGHT_STICK,
	"leftshoulder": JOY_BUTTON_LEFT_SHOULDER,
	"rightshoulder": JOY_BUTTON_RIGHT_SHOULDER,
	"dpup": JOY_BUTTON_DPAD_UP,
	"dpleft": JOY_BUTTON_DPAD_LEFT,
	"dpdown": JOY_BUTTON_DPAD_DOWN,
	"dpright": JOY_BUTTON_DPAD_RIGHT,

	# 摇杆
	"leftx": JOY_AXIS_LEFT_X,
	"lefty": JOY_AXIS_LEFT_Y,
	"rightx": JOY_AXIS_RIGHT_X,
	"righty": JOY_AXIS_RIGHT_Y,
	"lefttrigger": JOY_AXIS_TRIGGER_LEFT,
	"righttrigger": JOY_AXIS_TRIGGER_RIGHT,
}

## Xbox 手柄预设映射
const XBOX = {
	"a": "b0",
	"b": "b1",
	"y": "b3",
	"x": "b2",
	"start": "b7",
	"guide": "b8",
	"back": "b6",
	"leftstick": "b9",
	"rightstick": "b10",
	"leftshoulder": "b4",
	"rightshoulder": "b5",
	"dpup": "-a7",
	"dpleft":"-a6",
	"dpdown": "+a7",
	"dpright": "+a6",
	"leftx": "a0",
	"lefty": "a1",
	"rightx": "a3",
	"righty": "a4",
	"lefttrigger": "a2",
	"righttrigger": "a5",
}

## macOS 上 Xbox 手柄的预设映射
const XBOX_OSX = {
	"a": "b11",
	"b": "b12",
	"y": "b14",
	"x": "b13",
	"start": "b4",
	"back": "b5",
	"leftstick": "b6",
	"rightstick": "b7",
	"leftshoulder": "b8",
	"rightshoulder": "b9",
	"dpup": "b0",
	"dpleft": "b2",
	"dpdown": "b1",
	"dpright": "b3",
	"leftx": "a0",
	"lefty": "a1",
	"rightx": "a2",
	"righty": "a3",
	"lefttrigger": "a4",
	"righttrigger":"a5",
}

## 映射类型
var type := Type.NONE
## 按键/摇杆索引
var idx := -1
## 轴范围（仅对 AXIS 类型有效）
var axis := Axis.FULL
## 是否反转（仅对 AXIS 类型有效）
var inverted: bool = false


## 构造函数。
func _init(p_type: Type = Type.NONE, p_idx: int = -1, p_axis: Axis = Axis.FULL) -> void:
	type = p_type
	idx = p_idx
	axis = p_axis


## 生成 SDL2 格式的映射字符串。
## 格式: [+/-]b<索引> 或 [+/-]a<索引>[~]
func _to_string() -> String:
	if type == Type.NONE:
		return ""

	var ts: String = "b" if type == Type.BTN else "a"
	var prefix: String = ""
	var suffix: String = "~" if inverted else ""

	match axis:
		Axis.HALF_PLUS:
			prefix = "+"
		Axis.HALF_MINUS:
			prefix = "-"

	return "%s%s%d%s" % [prefix, ts, idx, suffix]


## 生成人类可读的映射描述字符串。
func to_human_string() -> String:
	if type == Type.BTN:
		return "Button %d" % idx

	if type == Type.AXIS:
		var prefix: String = ""
		match axis:
			Axis.HALF_PLUS:
				prefix = "(+) "
			Axis.HALF_MINUS:
				prefix = "(-) "
		var suffix: String = " (inverted)" if inverted else ""
		return "Axis %s%d%s" % [prefix, idx, suffix]

	return ""
