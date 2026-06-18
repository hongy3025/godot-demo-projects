## 手机传感器演示主脚本 —— 展示如何使用加速度计、重力、磁力计和陀螺仪数据。
##
## 该脚本继承自 [Node]，演示如何利用原始传感器数据确定手机/设备的朝向。
## 廉价手机通常只有加速度计，高端手机则拥有全部三种传感器。
## 注意：本演示未对数据进行滤波处理。滤波会引入延迟但能提供稳定性，
## 互联网上有大量实现滤波的示例代码，此处保持代码简洁易懂。
##
## 场景中绘制了多个箭头对象来可视化各个向量，以及两个立方体来展示两种
## 不同的手机朝向实现方案。这是一个 3D 示例，但读取手机朝向在 2D 应用中同样非常有价值。
extends Node


## 根据方向向量计算旋转矩阵（Basis）。
##
## 功能：给定一个方向向量，构造一个旋转矩阵使箭头指向该方向。
## 由于箭头是圆柱体，不需要关心绕自身轴的旋转。
## 参数：
##   p_vector: 方向向量（Vector3）
## 返回值：旋转矩阵（Basis）
## 算法：将 p_vector 归一化后作为 Y 轴，用叉积依次构造 X 轴和 Z 轴，
##       形成一个正交基。选取辅助向量时避开与 Y 轴接近平行的方向以防止退化。
func get_basis_for_arrow(p_vector: Vector3) -> Basis:
	var rotate := Basis()

	# 箭头默认朝上，因此将 Y 轴设为方向向量
	rotate.y = p_vector.normalized()

	# 选取一个任意向量用于计算另外两个轴
	var v := Vector3(1.0, 0.0, 0.0)
	if abs(v.dot(rotate.y)) > 0.9:
		v = Vector3(0.0, 1.0, 0.0)

	# 用叉积得到垂直于 Y 轴和 v 的向量作为 X 轴
	rotate.x = rotate.y.cross(v).normalized()

	# 再次叉积得到垂直于 X 轴和 Y 轴的 Z 轴
	rotate.z = rotate.x.cross(rotate.y).normalized()

	return rotate


## 结合磁力计和重力向量计算指向地理北方的向量。
##
## 功能：利用重力向量和磁力计读数计算水平面内指向北方的向量。
## 参数：
##   p_grav: 重力向量（Vector3），应指向地面方向
##   p_mag: 磁力计读数（Vector3）
## 返回值：指向北方的归一化向量（Vector3）
## 算法：先用重力与磁力叉积得到东西方向向量，再与重力叉积得到水平北向。
func calc_north(p_grav: Vector3, p_mag: Vector3) -> Vector3:
	# 始终使用归一化向量！
	p_grav = p_grav.normalized()

	# 重力向量与磁力向量叉积得到东西方向向量
	var east := p_grav.cross(p_mag.normalized()).normalized()

	# 东西向量与重力再次叉积得到水平北向向量
	return east.cross(p_grav).normalized()


## 使用磁力计和重力向量计算朝向矩阵。
##
## 功能：结合磁力计和重力读数，生成设备的朝向旋转矩阵。
## 参数：
##   p_mag: 磁力计读数（Vector3）
##   p_grav: 重力向量（Vector3）
## 返回值：朝向旋转矩阵（Basis）
## 算法：重力反方向作为 Y 轴（指向上方），Y 轴与磁北叉积得到 X 轴（东西方向），
##       再叉积得到 Z 轴（北向），构成正交基。
func orientate_by_mag_and_grav(p_mag: Vector3, p_grav: Vector3) -> Basis:
	var rotate := Basis()

	# 始终归一化
	p_mag = p_mag.normalized()

	# 重力指向下方，取反即指向上方
	rotate.y = -p_grav.normalized()

	# Y 轴与磁北叉积得到东西方向
	rotate.x = rotate.y.cross(p_mag)

	# 再次叉积得到北向，完成矩阵构建
	rotate.z = rotate.x.cross(rotate.y)

	return rotate


## 使用陀螺仪数据旋转朝向矩阵。
##
## 功能：陀螺仪数据不包含方向信息，而是旋转角速度。
## 因此需要将角速度乘以时间增量（delta）得到旋转角度，再应用到当前矩阵上。
## 参数：
##   p_gyro: 陀螺仪角速度（Vector3），单位弧度/秒
##   p_basis: 当前的朝向矩阵（Basis）
##   p_delta: 帧时间增量（float）
## 返回值：更新后的朝向矩阵（Basis）
func rotate_by_gyro(p_gyro: Vector3, p_basis: Basis, p_delta: float) -> Basis:
	var rotate := Basis()

	# 绕当前矩阵的各轴旋转对应的角度
	rotate = rotate.rotated(p_basis.x, -p_gyro.x * p_delta)
	rotate = rotate.rotated(p_basis.y, -p_gyro.y * p_delta)
	rotate = rotate.rotated(p_basis.z, -p_gyro.z * p_delta)

	return rotate * p_basis


## 使用重力向量对朝向矩阵进行漂移校正。
##
## 功能：陀螺仪长时间使用会产生累积漂移，利用重力向量作为参考进行校正。
## 参数：
##   p_basis: 需要校正的朝向矩阵（Basis）
##   p_grav: 重力向量（Vector3）
## 返回值：校正后的朝向矩阵（Basis）
## 算法：计算当前 Y 轴与真实向上方向的夹角，构造旋转矩阵进行校正。
func drift_correction(p_basis: Basis, p_grav: Vector3) -> Basis:
	# 重力取反得到真实的向上方向
	var real_up := -p_grav.normalized()

	# 计算当前 Y 轴与真实向上方向的点积（即夹角的余弦值）
	var dot := p_basis.y.dot(real_up)

	# 如果点积为 1.0，说明方向一致，无需校正
	if dot < 1.0:
		# 叉积得到垂直于两个向量的旋转轴
		var axis := p_basis.y.cross(real_up).normalized()
		var correction := Basis(axis, acos(dot))
		p_basis = correction * p_basis

	return p_basis


## 每帧更新 —— 读取传感器数据并更新场景中的可视化元素。
##
## 功能：从引擎获取加速度计、重力、磁力计和陀螺仪数据，更新 UI 显示数值，
##       并更新箭头和立方体的朝向。
## 参数：
##   delta: 帧时间增量（float），用于陀螺仪积分
## 返回值：无
func _process(delta: float) -> void:
	# 从引擎获取传感器读数
	var acc := Input.get_accelerometer()
	var grav := Input.get_gravity()
	var mag := Input.get_magnetometer()
	var gyro := Input.get_gyroscope()

	# 在 UI 上显示各传感器原始数值
	var format: String = "%.05f"

	%AccX.text = format % acc.x
	%AccY.text = format % acc.y
	%AccZ.text = format % acc.z

	%GravX.text = format % grav.x
	%GravY.text = format % grav.y
	%GravZ.text = format % grav.z

	%MagX.text = format % mag.x
	%MagY.text = format % mag.y
	%MagZ.text = format % mag.z

	%GyroX.text = format % gyro.x
	%GyroY.text = format % gyro.y
	%GyroZ.text = format % gyro.z

	# 检查是否有足够的数据
	if grav.length() < 0.1:
		if acc.length() < 0.1:
			# 两种数据都不可用，使用默认值
			grav = Vector3(0.0, -1.0, 0.0)
		else:
			# 重力向量由操作系统通过组合其他传感器输入计算得出。
			# 如果没有重力向量，则用加速度计代替
			grav = acc

	if mag.length() < 0.1:
		mag = Vector3(1.0, 0.0, 0.0)

	# 更新重力箭头朝向
	$Arrows/AccelerometerArrow.transform.basis = get_basis_for_arrow(grav)

	# 更新磁力计箭头朝向
	# 注意：在没有其他强磁场干扰的情况下，该箭头指向磁北，
	# 但由于地球是球体，磁北方向并不水平
	$Arrows/MagnetoArrow.transform.basis = get_basis_for_arrow(mag)

	# 计算北向向量并显示
	var north := calc_north(grav, mag)
	$Arrows/NorthArrow.transform.basis = get_basis_for_arrow(north)

	# 结合磁力计和重力向量定位立方体。这种方式相当准确，
	# 但磁力计容易受磁场干扰。廉价手机通常没有陀螺仪，
	# 因此这是一种很好的备选方案。
	var mag_and_grav: MeshInstance3D = $Boxes/MagAndGrav
	mag_and_grav.transform.basis = orientate_by_mag_and_grav(mag, grav).orthonormalized()

	# 使用陀螺仪并利用重力向量进行漂移校正可获得最佳效果
	var gyro_and_grav: MeshInstance3D = $Boxes/GyroAndGrav
	var new_basis := rotate_by_gyro(gyro, gyro_and_grav.transform.basis, delta).orthonormalized()
	gyro_and_grav.transform.basis = drift_correction(new_basis, grav)
