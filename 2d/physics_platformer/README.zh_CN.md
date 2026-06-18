# 物理平台游戏

本演示对玩家和敌人使用 [`RigidBody2D`](https://docs.godotengine.org/en/latest/classes/class_rigidbody2d.html)。这些角色控制器比 [`CharacterBody2D`](https://docs.godotengine.org/en/latest/classes/class_characterbody2d.html) 更强大，但处理起来可能更困难，因为它们需要手动修改 RigidDynamicBody 的速度。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2725

## 工作原理

玩家和敌人使用基于 [`RigidBody2D`](https://docs.godotengine.org/en/latest/classes/class_rigidbody2d.html) 的动态角色控制器进行移动，这意味着它们可以与物理引擎完美交互（有一个跷跷板，你甚至可以骑乘敌人）。因此，所有移动必须在 `_integrate_forces()` 中与物理引擎同步完成。

## 截图

![开始截图](screenshots/beginning.png)

![跷跷板和玩家骑乘敌人截图](screenshots/seesaw-riding.png)

## 音乐

"Pompy" by Hubert Lamontagne (madbr) https://soundcloud.com/madbr/pompy
