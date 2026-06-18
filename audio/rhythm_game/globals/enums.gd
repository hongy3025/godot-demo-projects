## 全局枚举定义 —— 提供游戏中使用的枚举类型。
##
## 通过 [code]class_name Enums[/code] 注册为全局类型，可在其他脚本中直接使用。
class_name Enums

## 时间类型枚举：决定使用哪种时间源来计算节拍。
enum TimeType {
	FILTERED,  ## 滤波后的时间（通过 1€ 滤波器平滑，更稳定）
	RAW,       ## 原始音频时间（更精确但可能有抖动）
}

## 击打判定类型枚举：记录每次按键的判定结果。
enum HitType {
	MISS_EARLY,   ## 过早按下（Miss）
	GOOD_EARLY,   ## 略早按下（Good）
	PERFECT,      ## 完美时机（Perfect）
	GOOD_LATE,    ## 略晚按下（Good）
	MISS_LATE,    ## 过晚按下（Miss）
}
