## 线程加载示例 —— 演示如何在 Godot 中使用 Thread（线程）在后台加载资源。
## 继承自 [Control]，作为 UI 界面的一部分。
## 核心流程：点击加载按钮 -> 启动新线程 -> 在线程中加载图片 -> 线程完成后将图片设置到 TextureRect 显示。
extends Control

## 线程对象引用。用于在后台执行资源加载，避免阻塞主线程。
var thread: Thread


## "加载"按钮的信号回调。点击后启动后台线程加载图片。
## 如果已有正在运行的线程，先等待其完成再启动新的。
func _on_load_pressed() -> void:
	# 检查线程是否有效且已启动，如果是则等待其完成
	if is_instance_valid(thread) and thread.is_started():
		# 如果已有线程在运行，让它先完成再启动新的
		thread.wait_to_finish()
	thread = Thread.new()
	print_rich("[b]Starting thread.")
	# 我们的方法需要一个参数，因此使用 bind() 传递
	thread.start(_bg_load.bind("res://mona.png"))


## 后台线程执行的加载函数。
## 参数:
##   path: 要加载的资源文件路径
## 返回: [Texture2D] 加载完成的纹理
## 注意: 此函数在子线程中运行，不能直接操作场景树中的节点。
##       必须通过 call_deferred() 让主线程在空闲时执行 UI 更新。
func _bg_load(path: String) -> Texture2D:
	print("Calling thread function.")
	var tex := load(path)
	# call_deferred() 告诉主线程在空闲时调用指定方法。
	# 我们的方法操作的是当前场景树中的节点，因此不能直接从另一个线程调用。
	_bg_load_done.call_deferred()
	return tex


## 后台加载完成后的回调函数（在主线程执行）。
## 等待线程结束并获取返回值，然后将纹理设置到 TextureRect 上显示。
func _bg_load_done() -> void:
	# 等待线程完成，并获取返回值
	var tex: Texture2D = thread.wait_to_finish()
	print_rich("[b][i]Thread finished.\n")
	$TextureRect.texture = tex
	# 线程使用完毕后释放引用。
	# Thread 是引用计数的，这样就能释放它。
	thread = null


## 节点退出场景树时的清理函数。
## 必须确保线程在释放前已经完成，否则可能导致资源未正确清理。
func _exit_tree() -> void:
	# 在线程被释放前，务必等待它完成！
	# 否则可能无法正确清理资源。
	if is_instance_valid(thread) and thread.is_started():
		thread.wait_to_finish()
		thread = null
