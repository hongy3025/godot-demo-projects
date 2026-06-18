# 3D 精灵和动画精灵

该项目演示了 Sprite3D 和 AnimatedSprite3D 在 3D 空间中的使用。

Sprite3D 和 AnimatedSprite3D 都是允许 2D 纹理或动画存在于 3D 世界中的节点。
它们对于使用传统 2D 资产的风格化或轻量级 3D 效果特别有用。

- **Sprite3D：** 在 3D 空间中渲染单个 2D 纹理或帧的节点。它可以像任何 3D 节点一样旋转、缩放和定位。可选地，它可以作为公告板始终面向摄像机。
- **AnimatedSprite3D：** 通过支持基于帧的动画扩展了 Sprite3D。你可以分配一个 SpriteFrames 资源来播放纹理序列，使其适用于 3D 中的角色精灵、视觉效果或翻书式动画。

两种类型都可以与自定义着色器结合，以模拟轮廓、光照效果或其他视觉增强。在大多数情况下，Sprite3D 用于静态图像或简单动画，而 AnimatedSprite3D 更适合复杂的动画或需要高效管理多个帧的情况。

此演示包括基本的旋转动画示例，并展示了如何对着色器应用于 Sprite3D 和 AnimatedSprite3D 以获得风格化效果。着色器演示还展示了如何创建类似纸张的效果，这对于在大多数游戏中创建独特的视觉风格非常有用。

语言：GDScript

渲染器：Forward+

## 截图

![Screenshot](screenshots/3d_sprites.webp)
