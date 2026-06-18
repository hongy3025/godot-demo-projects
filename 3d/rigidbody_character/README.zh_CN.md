# 刚体角色 3D

使用胶囊体作为角色的 3D 刚体角色演示。
立方体作为 RigidBody 从上方生成到地图中，以展示与玩家的交互
（跳上去、轻轻推动它们），这是 CharacterBody 无法实现的。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2750

## 工作原理

此演示使用 [`RigidBody3D`](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html)
作为玩家，使用 [`StaticBody3D`](https://docs.godotengine.org/en/latest/classes/class_staticbody3d.html)
作为关卡。每个都有碰撞体，玩家在 `_physics_process()` 中通过
`apply_central_impulse()` 移动自身，并与关卡碰撞。

[`ShapeCast3D`](https://docs.godotengine.org/en/latest/classes/class_shapecast3d.html) 节点用于检测玩家是否可以跳跃
（即接触地面）。与无限细的 [`RayCast3D`](https://docs.godotengine.org/en/latest/classes/class_raycast3d.html) 相比，
这可以更可靠地检查玩家是否站在边缘或角落上方。

## 截图

![Screenshot](screenshots/rigidbody_character.webp)
