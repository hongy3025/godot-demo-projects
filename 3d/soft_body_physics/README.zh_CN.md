# 3D 软体物理

[软体物理](https://docs.godotengine.org/en/latest/tutorials/physics/soft_body.html)
（可变形物体）的示例，如布料、盒子和球体。

软体支持固定点以及向特定点施加冲量/力，
这对于风等效果非常有用。

软体可以与静态体、刚体和角色体交互（并且在交互时会感知刚体的
重量）。然而，软体目前**不能**与其他软体交互，
这意味着它们会相互穿过。

每点冲量计时器示例还展示了如何将节点附加到 SoftBody3D 的特定点上。
这可用于使粒子、网格甚至刚体跟随特定点。

此演示中的布料软体使用启用了 **Grow** 属性的 BaseMaterial3D，以防止
可见的穿透到表面中。

控制：

- <kbd>R</kbd>：重置软体模拟和用户放置的物体
- <kbd>C</kbd>：在光标位置放置布料
- <kbd>V</kbd>：在光标位置放置轻盒子
- <kbd>B</kbd>：在光标位置放置重盒子

出于性能原因，此演示中一次最多只能存在 10 个用户放置的物体。
尝试放置超过 10 个物体时，最旧的物体将被移除。

语言：GDScript

渲染器：Forward+

## 截图

![Screenshot](screenshots/soft_body_physics.webp)
