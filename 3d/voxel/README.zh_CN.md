# 体素游戏

此演示是一个极简的第一人称体素游戏，
灵感来自其他游戏如 Minecraft。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2755

## 工作原理

每个区块是一个
[`StaticBody3D`](https://docs.godotengine.org/en/latest/classes/class_staticbody3d.html)，
每个方块有自己的
[`CollisionShape3D`](https://docs.godotengine.org/en/latest/classes/class_collisionshape3d.html)
用于碰撞。网格使用
[`SurfaceTool`](https://docs.godotengine.org/en/latest/classes/class_surfacetool.html)
创建，它允许指定顶点、三角形和 UV 坐标
来构建网格。

区块和区块数据存储在
[`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html)
对象中。新区块在单独的
[`Thread`](https://docs.godotengine.org/en/latest/classes/class_thread.html) 中绘制其网格，
但碰撞生成在主线程中完成，因为 Godot
不支持在单独的线程中更改物理对象。有
两种地形类型：随机方块和平坦草地。更复杂的地形生成器超出了此演示项目的范围。

玩家可以使用附加在摄像机上的
[`RayCast3D`](https://docs.godotengine.org/en/latest/classes/class_raycast3d.html)
节点放置和破坏方块。它使用碰撞信息来
确定方块位置并更改方块数据。你可以
使用方括号键或鼠标中键切换活动方块。

有一个用于渲染距离和切换雾的设置菜单。
设置存储在一个名为 "Settings" 的
[AutoLoad 单例](https://docs.godotengine.org/en/latest/tutorials/scripting/singletons_autoload.html)
中。此类使用
[`FileAccess`](https://docs.godotengine.org/en/latest/classes/class_fileaccess.html) 类
自动保存设置，并在游戏打开时加载它们。

像此演示一样坚持使用 GDScript 和 Godot 内置工具，
是相当有限的。如果你正在制作自己的体素游戏，你可能应该
使用 Zylann 的体素模块：https://github.com/Zylann/godot_voxel

## 截图

![Screenshot](screenshots/blocks.png)

![Screenshot](screenshots/title.png)

## 许可

纹理来自 [Minetest Game](https://github.com/minetest/minetest_game)。

部分纹理 Copyright &copy; 2010-2018 Minetest 贡献者，
CC BY-SA 3.0 Unported (Attribution-ShareAlike)
https://creativecommons.org/licenses/by-sa/3.0/

部分纹理 Copyright &copy; 2010-2018 Minetest 贡献者，
CC0 1.0 "No rights reserved"
https://creativecommons.org/publicdomain/zero/1.0/

字体 "TinyUnicode" 由 DuffsDevice 制作。Copyright &copy; DuffsDevice，CC-BY (Attribution) http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=468

### 从 Minetest Game 重用的纹理版权信息

虽然大多数纹理采用 CC BY-SA 3.0 许可，但部分采用 CC0 1.0 许可

Cisoun 的纹理包 (CC BY-SA 3.0)：

  * default\_stone.png
  * default\_leaves.png
  * default\_leaves\_simple.png
  * default\_tree.png
  * default\_tree\_top.png

celeron55, Perttu Ahola <celeron55@gmail.com> (CC BY-SA 3.0)

  * default\_mineral\_iron.png
  * default\_mineral\_coal.png
  * default\_bookshelf.png

VanessaE (CC BY-SA 3.0)：

  * default\_sand.png

Calinou (CC BY-SA 3.0)：

  * default\_brick.png

PilzAdam (CC BY-SA 3.0)：

  * default\_mineral\_gold.png

jojoa1997 (CC BY-SA 3.0)：

  * default\_obsidian.png

InfinityProject (CC BY-SA 3.0)：

  * default\_mineral\_diamond.png

Zeg9 (CC BY-SA 3.0)：

  * default\_coal\_block.png

paramat (CC BY-SA 3.0)：

  * default\_bush\_stem.png
  * default\_grass\_side.png -- 衍生自 TumeniNodes 的纹理 (CC-BY-SA 3.0)
  * default\_mese\_block.png

TumeniNodes (CC BY-SA 3.0)：

  * default\_grass.png

Blockmen (CC BY-SA 3.0)：

  * default\_wood.png

sofar (CC0 1.0)：

  * default\_gravel.png -- 衍生自 Gambit 的 PixelBOX 纹理包 light gravel

Neuromancer (CC BY-SA 3.0)：

  * default\_furnace\_bottom.png
  * default\_furnace\_side.png
  * default\_cobble.png，基于 Brane praefect 的纹理
  * default\_mossycobble.png，基于 Brane praefect 的纹理

Gambit (CC BY-SA 3.0)：

  * default\_diamond\_block.png

kilbith (CC BY-SA 3.0)：

  * default\_steel\_block.png
  * default\_gold\_block.png
  * default\_mineral\_tin.png

Mossmanikin (CC BY-SA 3.0)：

  * default\_fern\_3.png

random-geek (CC BY-SA 3.0)：

  * default\_dirt.png -- 衍生自 Neuromancer 的纹理 (CC BY-SA 3.0)

Krock (CC0 1.0)：

  * default\_glass.png
