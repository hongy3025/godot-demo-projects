## 玩家状态常量定义 —— 所有玩家状态的 StringName 常量字典。
## 继承自通用状态基类，定义玩家特有的状态名称。
extends "res://state_machine/state.gd"

## 玩家状态名称常量字典。
## 使用 StringName 类型以获得最佳性能。
const PLAYER_STATE: Dictionary[StringName, StringName]= {
	&"previous": &"previous",  # 回退到上一个状态
	&"jump": &"jump",          # 跳跃
	&"idle": &"idle",          # 待机
	&"move": &"move",          # 移动
	&"stagger": &"stagger",    # 踉跄
	&"attack": &"attack",      # 攻击
	&"die": &"die",            # 死亡
	&"dead": &"dead",          # 死亡完成
	&"walk": &"walk",          # 行走动画
}
