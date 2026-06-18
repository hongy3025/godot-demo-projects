# 3D 天空着色器

Godot 中天空着色器的一个示例。此着色器具有实时体积云
和带有瑞利散射和米氏散射的物理天空，这使得天空的
颜色根据太阳角度自动调整。太阳角度
从场景中的第一个 DirectionalLight3D 节点自动设置
（除非其天空模式设置为**仅光照**）。

物理天空功能基于内置的 PhysicalSkyMaterial，而
体积云是在使用编辑器资源下拉菜单中的**转换为 ShaderMaterial** 按钮
将 PhysicalSkyMaterial 转换为 ShaderMaterial 后添加的。

> **警告**
>
> 如果天空着色器使用 `TIME` 变量或每帧更新
>（例如，如果在 `_process()` 中或使用 AnimationPlayer 更新 uniform），
> 则它们每帧都会渲染。这对于复杂的天空着色器
> 有显著的性能影响。可以通过调整 Environment 中的
> 辐射度贴图属性来减少性能影响，但仍会很明显。
>
> 此演示项目中的着色器开销较大，适用于
> 大部分天空始终可见的游戏（如飞行模拟器）。
>
> 对天空着色器渲染的优化计划在未来的 Godot 版本中进行。

语言：GDScript

渲染器：Forward Plus

## 工作原理

昼夜循环使用 AnimationPlayer 节点实时调整节点属性和天空着色器参数。

具有不同粗糙度和金属材质级别的球体使用
[`@tool` 脚本](https://docs.godotengine.org/en/latest/tutorials/plugins/running_code_in_the_editor.html)
实例化，这样就不必在编辑器中手动创建，同时仍然可以在编辑器内预览。

## 截图

![Screenshot](screenshots/sky_shaders.webp)
