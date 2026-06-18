# 2D 粒子

本演示展示 2D 粒子系统在 Godot 中的工作方式。

语言：GDScript

渲染器：Mobile

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2724

## 工作原理

它使用带有 [`ParticleProcessMaterial`](https://docs.godotengine.org/en/latest/classes/class_particleprocessmaterial.html) 材质的 [`GPUParticles2D`](https://docs.godotengine.org/en/latest/classes/class_gpuparticles2d.html) 节点。请注意，`ParticleProcessMaterial` 在 2D 和 3D 之间是通用的，因此在 2D 中使用时，应启用"禁用 Z"标志。

## 截图

![粒子截图](screenshots/particles.webp)
