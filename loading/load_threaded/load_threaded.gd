## 多线程资源加载示例 —— 演示使用 ResourceLoader 的线程加载功能。
## 继承自 [VBoxContainer]，作为 UI 布局容器。
## 核心流程：点击"开始加载"按钮 -> 使用 load_threaded_request() 后台加载多张图片 ->
## 点击各图片按钮 -> 使用 load_threaded_get() 获取已加载的纹理并显示。
extends VBoxContainer


## "开始加载"按钮的信号回调。后台请求加载所有图片资源。
## 使用 load_threaded_request() 发起异步加载请求，不会阻塞主线程。
## 加载完成后启用各图片的显示按钮。
func _on_start_loading_pressed() -> void:
	ResourceLoader.load_threaded_request("res://paintings/painting_babel.jpg")
	ResourceLoader.load_threaded_request("res://paintings/painting_las_meninas.png")
	ResourceLoader.load_threaded_request("res://paintings/painting_mona_lisa.jpg")
	ResourceLoader.load_threaded_request("res://paintings/painting_old_guitarist.jpg")
	ResourceLoader.load_threaded_request("res://paintings/painting_parasol.jpg")
	ResourceLoader.load_threaded_request("res://paintings/painting_the_swing.jpg")
	# 启用所有图片获取按钮
	for current_button: Button in $GetLoaded.get_children():
		current_button.disabled = false


## "巴别塔"按钮的信号回调。获取已加载的巴别塔图片并显示。
func _on_babel_pressed() -> void:
	$Paintings/Babel.texture = ResourceLoader.load_threaded_get("res://paintings/painting_babel.jpg")
	$GetLoaded/Babel.disabled = true


## "宫娥"按钮的信号回调。获取已加载的宫娥图片并显示。
func _on_las_meninas_pressed() -> void:
	$Paintings/LasMeninas.texture = ResourceLoader.load_threaded_get("res://paintings/painting_las_meninas.png")
	$GetLoaded/LasMeninas.disabled = true


## "蒙娜丽莎"按钮的信号回调。获取已加载的蒙娜丽莎图片并显示。
func _on_mona_lisa_pressed() -> void:
	$Paintings/MonaLisa.texture = ResourceLoader.load_threaded_get("res://paintings/painting_mona_lisa.jpg")
	$GetLoaded/MonaLisa.disabled = true


## "老吉他手"按钮的信号回调。获取已加载的老吉他手图片并显示。
func _on_old_guitarist_pressed() -> void:
	$Paintings/OldGuitarist.texture = ResourceLoader.load_threaded_get("res://paintings/painting_old_guitarist.jpg")
	$GetLoaded/OldGuitarist.disabled = true


## "阳伞"按钮的信号回调。获取已加载的阳伞图片并显示。
func _on_parasol_pressed() -> void:
	$Paintings/Parasol.texture = ResourceLoader.load_threaded_get("res://paintings/painting_parasol.jpg")
	$GetLoaded/Parasol.disabled = true


## "秋千"按钮的信号回调。获取已加载的秋千图片并显示。
func _on_swing_pressed() -> void:
	$Paintings/Swing.texture = ResourceLoader.load_threaded_get("res://paintings/painting_the_swing.jpg")
	$GetLoaded/Swing.disabled = true
