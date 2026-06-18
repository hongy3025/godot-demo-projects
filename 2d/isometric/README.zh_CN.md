# 等距游戏

本演示展示具有深度排序的传统等距视图。

角色可以在关卡中移动，会绕过物体滑动，并且在站在物体前方或后方时会被遮挡。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2718

## 工作原理

关卡使用 [`TileMap`](https://docs.godotengine.org/en/latest/classes/class_tilemap.html#class-tilemap)，其中的瓦片具有不同的垂直偏移量。墙壁、门和柱子在其底部各有 [`StaticBody2D`](https://docs.godotengine.org/en/latest/classes/class_staticbody2d.html) 和 [`CollisionPolygon2D`](https://docs.godotengine.org/en/latest/classes/class_collisionpolygon2d.html)。玩家在其底部也有一个碰撞体，使玩家能够与关卡发生碰撞。

2D 光照效果通过混合使用 PointLight2D 节点（提供实时阴影）和预放置的带有精灵的 Polygon2D 来实现。为了提供额外的环境阴影，地精脚下还有一个 blob 阴影（一个带有纹理的 Sprite2D）。

## 截图

![截图](screenshots/isometric.webp)
