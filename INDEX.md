# Godot 官方示例项目索引

本仓库包含 **131 个** Godot 引擎官方示例项目，涵盖 2D、3D、音频、GUI、网络、XR 等多个领域。

---

## 目录

- [2D](#2d)
- [3D](#3d)
- [Audio（音频）](#audio音频)
- [Compute（计算着色器）](#compute计算着色器)
- [GUI（用户界面）](#gui用户界面)
- [Loading（加载）](#loading加载)
- [Misc（杂项）](#misc杂项)
- [Mobile（移动端）](#mobile移动端)
- [Mono（C#）](#monoc)
- [Networking（网络）](#networking网络)
- [Plugins（插件）](#plugins插件)
- [Viewport（视口）](#viewport视口)
- [XR（扩展现实）](#xr扩展现实)

---

## 2D

| 路径 | 名称 | 描述 |
|------|------|------|
| `2d/bullet_shower` | Bullet Shower | 演示如何使用底层服务（Servers）高效管理大量对象 |
| `2d/custom_drawing` | Custom Drawing in 2D | 演示如何在不使用节点的情况下绘制 2D 元素 |
| `2d/dodge_the_creeps` | Dodge the Creeps | 经典躲避游戏——玩家移动躲避敌人 |
| `2d/dynamic_tilemap_layers` | Dynamic TileMap Layers | 使用 CharacterBody2D 实现 2D 运动学角色控制器 |
| `2d/finite_state_machine` | Hierarchical Finite State Machine | 演示 GDScript 中的状态机编程模式，包括层次状态和下推自动机 |
| `2d/glow` | Glow for 2D | 通过 WorldEnvironment 节点在 2D 游戏中实现辉光效果 |
| `2d/hexagonal_map` | Hexagonal Game | 六边形 TileMap 和 TileSet 的简单演示 |
| `2d/instancing` | Scene Instancing Demo | 演示如何使用场景实例化创建大量对象副本 |
| `2d/isometric` | Isometric Game | 传统等距视图游戏，带深度排序 |
| `2d/kinematic_character` | Kinematic Character 2D | 使用 CharacterBody2D 的 2D 运动学角色控制器示例 |
| `2d/light2d_as_mask` | 2D Lights as Mask | 使用 2D 光源遮罩屏幕对象的示例 |
| `2d/lights_and_shadows` | 2D Lights and Shadows | 使用 PointLight2D 和 LightOccluder2D 的 2D 光照与阴影演示 |
| `2d/navigation` | Navigation Polygon 2D | 使用 NavigationPolygon 的 2D 导航示例 |
| `2d/navigation_astar` | Grid-based Pathfinding with AStarGrid2D | 使用 AStarGrid2D 进行网格寻路，含转向行为 |
| `2d/navigation_mesh_chunks` | Navigation Mesh Chunks 2D | 2D 导航网格分块演示 |
| `2d/particles` | 2D GPUParticles | 演示 Godot 中 2D 粒子系统的工作原理 |
| `2d/physics_platformer` | Physics-Based Platformer 2D | 使用 RigidBody2D 实现玩家和敌人的物理平台游戏 |
| `2d/physics_tests` | 2D Physics Tests | 2D 物理测试场景 |
| `2d/platformer` | Platformer 2D | 像素风格 2D 平台游戏，包含图形和音效，支持角色跳跃、射击、与敌人交互 |
| `2d/polygons_lines` | 2D Polygons and Lines | 使用 Polygon2D 和 Line2D 的实心/纹理多边形与线条演示 |
| `2d/pong` | Pong with GDScript | 经典 Pong 游戏，展示 Godot 最佳实践（包括信号） |
| `2d/role_playing_game` | JRPG Demo | 基于网格移动的 JRPG 风格游戏 |
| `2d/screen_space_shaders` | Screen Space Shaders | 多个全屏 2D 着色器处理示例 |
| `2d/skeleton` | Skeleton2D Demo | 使用 Skeleton2D 节点创建 2D 骨骼绑定动画角色 |
| `2d/sprite_shaders` | 2D Shaders for Sprites | 精灵着色器效果集合 |
| `2d/tween` | Tween Demo | 高级补间动画（Tween）用法演示 |

## 3D

| 路径 | 名称 | 描述 |
|------|------|------|
| `3d/antialiasing` | 3D Anti-Aliasing | 展示 Godot 支持的各种 3D 抗锯齿技术 |
| `3d/csg` | Constructive Solid Geometry (CSG) | 展示 Godot 的构造实体几何（CSG）功能 |
| `3d/decals` | Decals | 贴花（Decal）演示 |
| `3d/global_illumination` | Global Illumination | 展示 Godot 全局光照系统：LightmapGI、VoxelGI、SDFGI、ReflectionProbe 及 SSAO/SSIL 等屏幕空间效果 |
| `3d/graphics_settings` | 3D Graphics Settings | 3D 图形设置演示 |
| `3d/ik` | 3D Inverse Kinematics | Godot 中不同反向运动学（IK）算法的实现示例 |
| `3d/kinematic_character` | Kinematic Character 3D | 使用立方体的 3D 运动学角色演示 |
| `3d/labels_and_texts` | 3D Labels and Texts | 展示在 3D 空间中绘制文本的两种方式：Label3D 和 TextMesh |
| `3d/lights_and_shadows` | 3D Lights and Shadows | 展示 Godot 支持的各种 3D 光照和阴影功能 |
| `3d/material_testers` | Material Testers | 包含多种复杂材质的球体，展示 Godot 渲染能力 |
| `3d/navigation` | 3D Navigation | 3D 场景导航演示，角色可在静态 3D 环境中寻路 |
| `3d/navigation_mesh_chunks` | Navigation Mesh Chunks 3D | 3D 导航网格分块演示 |
| `3d/occlusion_culling_mesh_lod` | Occlusion Culling and Mesh LOD | 演示遮挡剔除和网格 LOD（细节层次）在 3D 场景中的应用 |
| `3d/particles` | 3D Particles | 展示 Godot 支持的 GPU 和 CPU 3D 粒子功能 |
| `3d/physical_light_camera_units` | Physical Light and Camera Units | 物理光照和摄像机单位设置演示 |
| `3d/physics_interpolation` | Physics Interpolation | 3D 物理插值演示，含多种摄像机模式 |
| `3d/physics_tests` | 3D Physics Tests | 3D 物理测试场景 |
| `3d/platformer` | Platformer 3D | 使用 CharacterBody3D 的 3D 平台游戏 |
| `3d/procedural_materials` | Procedural Materials | 程序化材质演示 |
| `3d/ragdoll_physics` | Ragdoll Physics | 角色布娃娃物理模拟示例 |
| `3d/rigidbody_character` | RigidBody Character 3D | 使用胶囊体的 3D 刚体角色演示 |
| `3d/sky_shaders` | 3D Sky Shaders | 使用天空着色器渲染实时体积云 |
| `3d/soft_body_physics` | Soft Body Physics | 软体物理示例（布料、箱子、球体等可变形物体） |
| `3d/sprites` | 3D Sprites and Animated Sprites | 在 3D 环境中使用 Sprite3D 和 AnimatedSprite3D |
| `3d/squash_the_creeps` | Squash the Creeps (3D) | 追逐并消灭怪物的 3D 游戏，对应官方教程"你的第一个 3D 游戏" |
| `3d/tonemap_color_correction` | Tonemapping and Color Correction | 展示各种色调映射算子及其与颜色校正纹理的交互 |
| `3d/truck_town` | Truck Town | 使用车辆物理实现不同类型卡车的演示 |
| `3d/variable_rate_shading` | Variable Rate Shading | 演示如何在 3D 中使用可变速率着色（VRS）提升性能 |
| `3d/visibility_ranges` | Visibility Ranges (HLOD) | 使用可见性范围设置层次化 LOD 系统 |
| `3d/volumetric_fog` | Volumetric Fog | 体积雾效果演示 |
| `3d/voxel` | Voxel Game | 受 Minecraft 启发的体素游戏最小实现 |
| `3d/waypoints` | 3D Waypoints | 在不依赖视口的情况下在 3D 世界中显示 GUI 元素（如标签） |

## Audio（音频）

| 路径 | 名称 | 描述 |
|------|------|------|
| `audio/audio_effects` | Audio Effects | 展示 Godot 中可用的各种音频效果 |
| `audio/bpm_sync` | BPM Sync Demo | 演示如何将音频播放与时间同步以实现稳定的 BPM |
| `audio/device_changer` | Audio Device Changer Demo | 演示如何在 Godot 中切换音频输出设备 |
| `audio/generator` | Audio Generator Demo | 演示如何从 GDScript 生成和播放音频样本 |
| `audio/mic_record` | Audio Mic Record Demo | 演示如何从麦克风录制音频并回放或保存到文件 |
| `audio/midi_piano` | MIDI Piano Demo | MIDI 钢琴演示 |
| `audio/rhythm_game` | Rhythm Game | 利用精确播放位置实现的简单节奏游戏 |
| `audio/spectrum` | Audio Spectrum Demo | 使用 Godot 构建频谱分析仪的演示 |
| `audio/text_to_speech` | Text-to-speech demo | 文本转语音（TTS）功能演示 |

## Compute（计算着色器）

| 路径 | 名称 | 描述 |
|------|------|------|
| `compute/heightmap` | Compute Shader Heightmap | 计算着色器生成高度图 |
| `compute/post_shader` | Compositor Effects (Post-Processing) | 合成器后处理效果演示 |
| `compute/texture` | Compute Texture | 计算着色器纹理处理演示 |

## GUI（用户界面）

| 路径 | 名称 | 描述 |
|------|------|------|
| `gui/accessibility` | UI Accessibility | Godot UI 无障碍功能演示 |
| `gui/bidi_and_font_features` | BiDi and Font Features | 双向文本和字体特性演示 |
| `gui/control_gallery` | Control Gallery | 展示各种 Control 节点，附名称标识便于识别 |
| `gui/drag_and_drop` | Drag & Drop (GUI) | 拖放功能演示 |
| `gui/gd_paint` | GD Paint | 使用 Godot 和 GDScript 制作的简易图像编辑器 |
| `gui/input_mapping` | Input Mapping GUI | 构建输入按键重映射界面的演示 |
| `gui/msdf_font` | Multi-channel Signed Distance Field Font Demo | Godot 中 SDF 字体（多通道有符号距离场字体）的演示 |
| `gui/multiple_resolutions` | Multiple Resolutions and Aspect Ratios | 演示如何配置项目以适配多种分辨率和宽高比 |
| `gui/pseudolocalization` | Pseudolocalization | 伪本地化功能演示 |
| `gui/regex` | RegEx (Regular Expressions) | 正则表达式功能和使用演示 |
| `gui/rich_text_bbcode` | Rich Text Label with BBCode | 通过 RichTextLabel 展示富文本和 BBCode 支持 |
| `gui/theming_override` | GUI Theming Override | 演示如何在运行时覆盖 GUI 颜色和样式盒 |
| `gui/translation` | Translation Demo | 演示 Godot 如何无缝使用本地化资源和文本 |
| `gui/ui_mirroring` | UI Mirroring Demo | UI 镜像（从右到左布局）演示 |

## Loading（加载）

| 路径 | 名称 | 描述 |
|------|------|------|
| `loading/autoload` | Autoload (Singletons) | 演示如何使用自动加载（单例）切换场景 |
| `loading/load_threaded` | Threaded Loading | 演示如何使用 ResourceLoader 进行后台加载 |
| `loading/runtime_save_load` | Run-time File Saving and Loading | 演示如何在不经过 Godot 资源导入系统的情况下加载和保存各种文件类型 |
| `loading/scene_changer` | Scene Changer | 使用 SceneTree 函数在两个场景之间切换 |
| `loading/serialization` | Saving and Loading (Serialization) | 演示使用 ConfigFile 和 JSON 格式保存游戏 |
| `loading/threads` | Loading in a Thread | 使用线程加载图像的示例 |

## Misc（杂项）

| 路径 | 名称 | 描述 |
|------|------|------|
| `misc/2.5d` | 2.5D Demo with GDScript | 通过混合 2D 和 3D 节点创建 2.5D 游戏 |
| `misc/custom_logging` | Custom Logging | 自定义日志记录器实现，与内置日志并行运行 |
| `misc/graphics_tablet_input` | Graphics Tablet Input | 在 Godot 中使用数位板输入的演示 |
| `misc/hdr_output` | HDR Output | 高动态范围（HDR）输出及最佳实践 |
| `misc/joypads` | Joypads | 手柄输入测试工具 |
| `misc/large_world_coordinates` | Large World Coordinates | 演示双精度渲染和物理的可选支持 |
| `misc/matrix_transform` | Matrix Transform | 可视化变换（Transform）工作原理的演示场景 |
| `misc/multiple_windows` | Multiple Windows Demo | 展示所有 Window 类及其在主窗口中的使用 |
| `misc/noise_viewer` | Noise Viewer | 允许用户调整 FastNoiseLite 纹理不同参数的示例项目 |
| `misc/os_test` | Operating System Testing | 展示 Godot 中各种操作系统特定功能 |
| `misc/pause` | Pause | 演示如何在 Godot 中暂停游戏 |
| `misc/window_management` | Window Management | 通过 DisplayServer 实现的各种窗口管理功能演示 |

## Mobile（移动端）

| 路径 | 名称 | 描述 |
|------|------|------|
| `mobile/android_iap` | Android In-App Purchases | 演示如何在 Android 中实现应用内购买 |
| `mobile/multitouch_cubes` | Multitouch Cubes Demo | 使用触摸 API 的多点触控输入和手势演示 |
| `mobile/multitouch_view` | Multitouch View | 多点触控输入调试器，显示触摸位置 |
| `mobile/sensors` | Mobile Sensors Demo | 演示加速度计、陀螺仪和磁力计等传感器使用 |

## Mono（C#）

| 路径 | 名称 | 描述 |
|------|------|------|
| `mono/2.5d` | 2.5D Demo with C# | 使用 C# 混合 2D 和 3D 节点创建 2.5D 游戏 |
| `mono/android_iap` | Android in-app purchases with C# | 使用 C# 在 Android 中实现应用内购买 |
| `mono/dodge_the_creeps` | Dodge the Creeps with C# | 使用 C# 实现的躲避游戏 |
| `mono/multiplayer_pong` | Pong Multiplayer with C# | 使用 C# 实现的多人 Pong 游戏 |
| `mono/pong` | Pong with C# | 使用 C# 实现的经典 Pong 游戏 |
| `mono/squash_the_creeps` | Squash the Creeps (3D) with C# | 使用 C# 实现的 3D 消灭怪物游戏 |

## Networking（网络）

| 路径 | 名称 | 描述 |
|------|------|------|
| `networking/multiplayer_bomber` | Multiplayer Bomber | 经典炸弹人游戏的多人实现 |
| `networking/multiplayer_pong` | Pong Multiplayer | 经典 Pong 游戏的多人版本 |
| `networking/webrtc_minimal` | WebRTC Minimal Connection | 使用 WebRTC 连接两个对等端的最小示例 |
| `networking/webrtc_signaling` | WebRTC Signaling Example | WebRTC 的 WebSocket 信令服务器/客户端 |
| `networking/websocket_chat` | WebSocket Chat Demo | 使用 WebSocket 实现的简单聊天演示 |
| `networking/websocket_minimal` | WebSocket Minimal Demo | 使用 WebSocket 连接两个对等端的最小示例 |
| `networking/websocket_multiplayer` | WebSocket Multiplayer Demo | 演示如何将 WebSocket 与 Godot 多人 API 结合使用 |

## Plugins（插件）

| 路径 | 名称 | 描述 |
|------|------|------|
| `plugins` | Plugin Demos | 包含 4 个编辑器插件演示：自定义节点、材质导入、材质创建器和主屏幕插件 |

## Viewport（视口）

| 路径 | 名称 | 描述 |
|------|------|------|
| `viewport/2d_in_3d` | 2D in 3D | 演示如何使用视口在 3D 场景中显示 2D 场景 |
| `viewport/3d_in_2d` | 3D in 2D | 演示如何使用视口在 2D 场景中显示 3D 场景 |
| `viewport/3d_scaling` | 3D SubViewport Scaling | 演示如何缩放 3D 视口渲染而不影响 HUD 等 2D 元素 |
| `viewport/dynamic_split_screen` | Dynamic Split Screen | 使用 Godot 着色器语言实现动态分屏（Voronoi 分屏） |
| `viewport/gui_in_3d` | GUI in 3D | 在 3D 场景中实例化 GUI，并将鼠标和键盘输入转发到 GUI |
| `viewport/screen_capture` | Screen Capture | 屏幕截图示例 |
| `viewport/split_screen_input` | Split Screen Input | 分屏输入处理演示 |

## XR（扩展现实）

| 路径 | 名称 | 描述 |
|------|------|------|
| `xr/mobile_vr_interface_demo` | Mobile VR Stereo Interface Demo | 移动 VR 立体界面演示 |
| `xr/openxr_binding_modifier_demo` | OpenXR Binding Modifiers Demo | OpenXR 绑定修饰符演示 |
| `xr/openxr_character_centric_movement` | OpenXR Character Centric Movement | OpenXR 以角色为中心的移动演示 |
| `xr/openxr_composition_layers` | OpenXR Composition Layers | OpenXR 合成层演示 |
| `xr/openxr_hand_tracking_demo` | OpenXR Hand Tracking Demo | OpenXR 手部追踪演示 |
| `xr/openxr_origin_centric_movement` | OpenXR Origin Centric Movement | OpenXR 以原点为中心的移动演示 |
| `xr/openxr_passthrough` | OpenXR Passthrough demo | OpenXR 透视（Passthrough）演示 |
| `xr/openxr_render_models` | OpenXR Render Models | OpenXR 渲染模型演示 |
| `xr/openxr_spectator_view` | Openxr Spectator View Demo | OpenXR 旁观者视角演示 |
| `xr/webxr` | WebXR demo | WebXR 演示 |

---

> 生成日期：2026-06-18 | 项目总数：131
