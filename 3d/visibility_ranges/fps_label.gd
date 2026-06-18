## FPS 显示标签 —— 实时显示帧率和帧时间。
##
## 继承自 [Label]，每帧更新显示当前 FPS 和每帧耗时（毫秒）。
extends Label


## _process 入口。每帧更新 FPS 和帧时间文本。
func _process(_delta: float) -> void:
	var fps: float = Engine.get_frames_per_second()
	text = "%d FPS (%.2f mspf)" % [fps, 1000.0 / fps]
