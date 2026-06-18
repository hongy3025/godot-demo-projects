# Navigation Mesh Chunks 2D - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何为大型世界分块系统烘焙导航网格（Navigation Mesh）。将大世界划分为多个 Chunk，每个 Chunk 独立烘焙导航网格，并在边界处正确对齐。

## 2. 快速上手

运行 `navmesh_chunks_demo_2d.tscn`，鼠标悬停查看导航网格上的最近点，左键设置路径起点。

## 3. 核心架构

```
navmesh_chunks_demo_2d.tscn
├── ParseRootNode          ← 碰撞体解析根节点
├── ChunksContainer        ← 分块容器
├── DebugPaths             ← 调试路径显示
└── 多个 NavigationAgent2D  ← 不同路径后处理模式
```

## 4. 文件逐层导读

### `navmesh_chunks_demo_2d.gd` — 分块导航系统 ⭐

**静态变量：**
```gdscript
static var chunk_size: int = 256
static var agent_radius: float = 10.0
static var chunk_id_to_region: Dictionary = {}
```

**分块创建流程：**
1. 解析场景中所有静态碰撞体到 `NavigationMeshSourceGeometryData2D`
2. 添加可遍历轮廓（traversable outline）
3. 计算所需 Chunk 范围
4. 对每个 Chunk：
   - 扩大烘焙边界（`grow(chunk_size)`）使边缘对齐
   - 独立烘焙导航网格
   - 创建 `NavigationRegion2D` 添加到场景

```gdscript
var baking_bounds = chunk_bounding_box.grow(p_chunk_size)
chunk_navmesh.baking_rect = baking_bounds
chunk_navmesh.border_size = p_chunk_size
```

**顶点对齐：**
```gdscript
navmesh_vertices[i] = vertex.snappedf(map_cell_size * 0.1)
```

## 5. 关键概念详解

### 分块导航网格

大型世界需要分块烘焙的原因：
- 整个世界一次烘焙内存消耗过大
- 局部更新时只需重新烘焙受影响的分块
- 支持流式加载（只加载玩家附近的分块）

### 边界对齐

每个 Chunk 的烘焙范围比自身大（`grow(chunk_size)`），这样相邻 Chunk 的导航网格在边界处共享顶点，确保路径可以跨 Chunk 连通。

### 路径后处理模式

项目演示了三种路径后处理：
- Corridor Funnel：走廊漏斗算法，生成最短路径
- Edge Centered：边缘居中
- No Post Processing：无后处理

## 6. 场景树全景

```
NavmeshChunksDemo2D (Node2D)
├── ParseRootNode
├── ChunksContainer
│   ├── NavigationRegion2D (Chunk 0,0)
│   ├── NavigationRegion2D (Chunk 1,0)
│   └── ...
├── DebugPaths
├── PathDebugCorridorFunnel (NavigationAgent2D)
├── PathDebugEdgeCentered (NavigationAgent2D)
└── PathDebugNoPostProcessing (NavigationAgent2D)
```

## 7. 如何扩展

- 实现动态加载/卸载：根据玩家位置创建/移除 Chunk
- 调整 `chunk_size` 和 `agent_radius` 适配不同游戏需求
- 添加障碍物后重新烘焙受影响 Chunk
