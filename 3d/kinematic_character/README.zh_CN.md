# 运动学角色 3D

使用立方体作为角色的 3D 运动学角色演示。
这与 3D 平台游戏演示类似。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2739

## 工作原理

此演示使用 [`CharacterBody3D`](https://docs.godotengine.org/en/latest/classes/class_characterbody3d.html)
作为玩家，使用 [`StaticBody3D`](https://docs.godotengine.org/en/latest/classes/class_staticbody3d.html)
作为关卡。每个都有碰撞体，玩家在 `_physics_process()` 中通过
`move_and_slide()` 移动自身，并与关卡碰撞。

## 截图

![Screenshot](screenshots/kinematic_character.webp)
