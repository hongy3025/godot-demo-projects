## 速度表 —— 显示车辆速度并支持单位切换。
##
## 继承自 [Button]，显示当前速度（m/s、km/h 或 mph），
## 根据速度改变颜色，点击可切换速度单位。
extends Button

## 速度单位枚举。
enum SpeedUnit {
	METERS_PER_SECOND,  ## 米/秒。
	KILOMETERS_PER_HOUR, ## 公里/小时。
	MILES_PER_HOUR,     ## 英里/小时。
}

## 关联的车辆刚体引用。
var car_body: VehicleBody3D

## 速度颜色渐变（低速到高速）。
@export var tint_gradient: Gradient
## 当前速度单位。
@export var speed_unit: SpeedUnit = SpeedUnit.METERS_PER_SECOND

## _process 入口。每帧更新速度显示和颜色。
func _process(_delta: float) -> void:
	var speed := car_body.linear_velocity.length()
	if speed_unit == SpeedUnit.METERS_PER_SECOND:
		text = "速度: " + ("%.1f" % speed) + " m/s"
	elif speed_unit == SpeedUnit.KILOMETERS_PER_HOUR:
		speed *= 3.6
		text = "速度: " + ("%.0f" % speed) + " km/h"
	else:
		speed *= 2.23694
		text = "速度: " + ("%.0f" % speed) + " mph"

	# 根据速度改变颜色（以 m/s 为准）。
	add_theme_color_override(&"font_color", tint_gradient.sample(remap(car_body.linear_velocity.length(), 0.0, 30.0, 0.0, 1.0)))


## 速度表点击回调。循环切换速度单位。
func _on_speedometer_pressed() -> void:
	speed_unit = ((speed_unit + 1) % SpeedUnit.size()) as SpeedUnit
