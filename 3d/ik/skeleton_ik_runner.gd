## SkeletonIK3D 启动器 —— 在 _ready 时启动 IK 求解。
##
## 继承自 [SkeletonIK3D]，自动开始 IK 求解。
extends SkeletonIK3D

## _ready 入口。启动 IK 求解。
func _ready():
	start(false)
