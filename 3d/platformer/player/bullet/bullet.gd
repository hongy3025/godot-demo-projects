## 子弹 —— 可被玩家发射的刚体子弹。
##
## 继承自 [RigidBody3D]，击中敌人后禁用以防止多次伤害。
class_name Bullet
extends RigidBody3D

## 如果为 `true`，子弹可以击中敌人。
## 击中敌人后设为 `false`，防止子弹在淡出期间多次击中敌人。
var enabled: bool = true
