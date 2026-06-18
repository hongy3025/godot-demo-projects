# 2D 平台游戏

本演示是一个像素风格 2D 平台游戏，包含图形和音效。

它展示了如何在真实的游戏环境中编写角色和基于物理的对象。这是一个相对完整的演示，玩家可以跳跃、在斜坡上行走、发射子弹、与敌人互动等。它包含一个封闭的关卡，玩家是无敌的，而敌人则不是。

你可以在 `level.tscn` 场景中找到演示的大部分内容。你可以从默认的 `game.tscn` 场景打开它，或者双击 `src/level/` 目录中的 `level.tscn`。

我们建议你在编辑器中打开演示的 GDScript 文件，因为它们包含大量注释，解释每个类的工作原理。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/120

## 功能特性

- 使用 [`CharacterBody2D`](https://docs.godotengine.org/en/latest/classes/class_characterbody2d.html) 的横版卷轴玩家控制器。
    - 可以在斜坡上行走并吸附。
    - 可以射击，包括跳跃时射击。
- 在地面上爬行的敌人，遇到障碍物时改变方向。
- 保持在关卡边界内的摄像机。
- 支持键盘和游戏手柄控制。
- 可以向任意方向移动的平台。
- 发射具有刚体（自然）物理的子弹的枪。
- 可收集的金币。
- 暂停和暂停菜单。
- 像素风格视觉效果。
- 音效和音乐。

## 截图

![2D 平台游戏](screenshots/platformer.webp)

## 音乐

[*Pompy*](https://soundcloud.com/madbr/pompy) by Hubert Lamontagne (madbr)
