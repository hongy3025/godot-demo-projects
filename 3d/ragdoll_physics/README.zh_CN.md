# 布娃娃物理

此演示包含角色布娃娃模拟的示例。

此演示中的布娃娃设置是按照[布娃娃系统](https://docs.godotengine.org/en/stable/tutorials/physics/ragdoll_system.html)
教程进行的。角色脚本还实现了一个 `initial_velocity` 变量，
它将为布娃娃系统所有骨骼施加一个冲量。
这种初始冲量通常在游戏中用于使布娃娃效果更具冲击力，
例如在受到拳击后增加额外的后坐力。

碰撞声音根据碰撞速度播放，并且在启用慢动作模式时
以降低的音高播放。这使用了
`AudioServer.playback_speed_scale`，它会影响所有音频，
因此在更复杂的项目中，你应该使用
[音频总线](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html)，
这样可以使效果仅应用于某些声音。这可用于保持
音乐不受音高变化效果的影响。

角色模型使用 BaseMaterial3D 的 **Stencil > Mode** 属性提供的轮廓。
场景的静态几何体使用 CSG 节点设计，并烘焙为
静态网格和碰撞体，以改善加载时间并允许使用 LightmapGI 进行全局光照。

控制：

- <kbd>Space</kbd>：在鼠标光标位置添加一个布娃娃
- <kbd>Shift</kbd>（按住）：启用慢动作模式（1/4 速度）
- <kbd>R</kbd>：重置布娃娃模拟并移除用户放置的布娃娃
- <kbd>鼠标右键</kbd>：环绕摄像机
- <kbd>鼠标滚轮</kbd>：缩放

语言：GDScript

渲染器：Forward+

## 截图

![Screenshot](screenshots/ragdoll_physics.webp)
