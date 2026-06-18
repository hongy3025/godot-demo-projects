## 全局设置 —— 节奏游戏的全局配置单例。
##
## 继承自 [Node]，存储所有可调整的游戏参数，
## 通过信号通知参数变更，支持在编辑器中直接修改。
extends Node

## 滚动速度变化信号，用于通知音符等节点更新速度。
signal scroll_speed_changed(speed: float)

## 是否使用滤波后的播放时间（通过 1€ 滤波器平滑音频时钟）。
@export var use_filtered_playback: bool = true

## 是否启用节拍器音效。
@export var enable_metronome: bool = false
## 输入延迟（毫秒），用于补偿玩家输入到音频播放之间的延迟。
@export var input_latency_ms: int = 20

## 音符滚动速度（像素/秒）。通过 setter 在变化时发射信号。
@export var scroll_speed: float = 400:
	set(value):
		if scroll_speed != value:
			scroll_speed = value
			scroll_speed_changed.emit(value)
## 是否显示击打偏移量（毫秒）。
@export var show_offsets: bool = false

## 当前选中的曲谱。
@export var selected_chart: ChartData.Chart = ChartData.Chart.THE_COMEBACK
