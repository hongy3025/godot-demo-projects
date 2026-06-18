# Truck Town

这是一个使用车辆物理实现不同复杂度卡车的演示。

## 控制：

- <kbd>上箭头</kbd>、<kbd>W</kbd>、<kbd>手柄右扳机</kbd>：加速
- <kbd>下箭头</kbd>、<kbd>S</kbd>、<kbd>Space</kbd>、<kbd>手柄左扳机</kbd>、<kbd>手柄 B/圆圈</kbd>、<kbd>手柄 X/方块</kbd>：刹车/倒车
- <kbd>左箭头</kbd>、<kbd>手柄左摇杆</kbd>、<kbd>手柄方向键左</kbd>：左转
- <kbd>右箭头</kbd>、<kbd>手柄左摇杆</kbd>、<kbd>手柄方向键右</kbd>：右转
- <kbd>U</kbd>、<kbd>手柄 Select</kbd>、左键点击速度表：更改速度表单位（m/s、km/h、mph）
- <kbd>C</kbd>、<kbd>手柄 Y/三角形</kbd>：切换摄像机（外部、内部、俯视）
- <kbd>M</kbd>、<kbd>手柄方向键下</kbd>：切换氛围（日出、白天、日落、夜晚）
- <kbd>Shift</kbd>、<kbd>手柄 A/Cross</kbd>：使用加速
- <kbd>H</kbd>、<kbd>Enter</kbd>、<kbd>手柄左摇杆按下</kbd>：按喇叭
- <kbd>L</kbd>、<kbd>手柄右摇杆按下</kbd>：切换前大灯（氛围变化时自动触发）
- <kbd>Escape</kbd>、<kbd>手柄方向键上</kbd>：返回菜单（再次按下退出）

在移动平台上，车辆会自动加速。触摸屏幕的左右边缘进行转向。触摸屏幕中间进行刹车/倒车（这也会暂时停止加速）。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2752

## 工作原理

基础车辆使用 [`VehicleBody3D`](https://docs.godotengine.org/en/latest/classes/class_vehiclebody3d.html) 节点。拖车卡车使用 [`ConeJointTwist3D`](https://docs.godotengine.org/en/latest/classes/class_conetwistjoint3d.html) 节点连接在一起，拖车使用由 [`RigidBody3D`](https://docs.godotengine.org/en/latest/classes/class_rigidbody3d.html) 节点组成的链条连接在一起，这些节点使用 [`PinJoint3D`](https://docs.godotengine.org/en/latest/classes/class_pinjoint3d.html) 节点固定在一起。

## 致谢

### 环境音效

- [Sunrise](https://freesound.org/people/nyoz/sounds/614202/) 由 nyoz 制作
- [Day](https://freesound.org/people/pawsound/sounds/154880/) 由 pawsound 制作
- [Sunset](https://freesound.org/people/roisin.gleeson/sounds/699131/) 由 roisin.gleeson 制作
- [Night](https://freesound.org/people/DidntGoToFilmSchool/sounds/248103/) 由 DidntGoToFilmSchool 制作

## 模型

- [tree low-poly](https://sketchfab.com/3d-models/tree-low-poly-4cd243eb74c74b3ea2190ebcec0439fb) 由 Ricardo Sanchez (https://sketchfab.com/380660711785) 制作
- [Lowpoly lamp](https://sketchfab.com/3d-models/lowpoly-lamp-c020f6af78f7482f8cf2ac84d05c08a5) 由 RitiWox (https://sketchfab.com/RitiWox) 制作

## 截图

![Screenshot](screenshots/truck_town.webp)
