## 运行时文件加载/导出工具 —— 演示在运行时加载和导出各种类型的资源文件。
## 继承自 [Control]，提供完整的 UI 界面。
## 支持的文件类型：图片（jpg/png/webp/svg/tga/bmp）、音频（ogg/mp3/wav）、
## 3D 场景（gltf/glb/fbx）、字体（ttf/otf/woff/woff2/pfb/pfm/fnt/font）、
## ZIP 压缩包以及纯文本文件。
## 同时支持将已加载的资源导出为文件。
extends Control

## 文件路径输入框的引用。
@onready var file_path_edit := $MarginContainer/VBoxContainer/HBoxContainer/FilePath as LineEdit
## 文件选择对话框的引用。
@onready var file_dialog := $MarginContainer/VBoxContainer/HBoxContainer/FileDialog as FileDialog
## 纯文本查看器的引用（滚动容器）。
@onready var plain_text_viewer := $MarginContainer/VBoxContainer/Result/PlainTextViewer as ScrollContainer
## 纯文本查看器中显示内容的 Label 引用。
@onready var plain_text_viewer_label := $MarginContainer/VBoxContainer/Result/PlainTextViewer/Label as Label
## 图片查看器的引用（TextureRect）。
@onready var texture_viewer := $MarginContainer/VBoxContainer/Result/TextureViewer as TextureRect
## 音频播放器按钮的引用。
@onready var audio_player := $MarginContainer/VBoxContainer/Result/AudioPlayer as Button
## 音频播放器中显示时长信息的 Label 引用。
@onready var audio_player_information := $MarginContainer/VBoxContainer/Result/AudioPlayer/Information as Label
## 音频流播放器的引用，用于播放音频。
@onready var audio_stream_player := $MarginContainer/VBoxContainer/Result/AudioPlayer/AudioStreamPlayer as AudioStreamPlayer
## 3D 场景查看器的引用（SubViewportContainer，包含 3D 渲染子视口）。
@onready var scene_viewer := $MarginContainer/VBoxContainer/Result/SceneViewer as SubViewportContainer
## 3D 场景查看器中的摄像机引用。
@onready var scene_viewer_camera := $MarginContainer/VBoxContainer/Result/SceneViewer/SubViewport/Camera3D as Camera3D
## 字体查看器的引用（Label，用于预览字体效果）。
@onready var font_viewer := $MarginContainer/VBoxContainer/Result/FontViewer as Label
## ZIP 压缩包查看器的引用（水平分割容器，左侧文件列表，右侧预览）。
@onready var zip_viewer := $MarginContainer/VBoxContainer/Result/ZIPViewer as HSplitContainer
## ZIP 文件列表的引用（ItemList，显示压缩包内的文件列表）。
@onready var zip_viewer_file_list := $MarginContainer/VBoxContainer/Result/ZIPViewer/FileList as ItemList
## ZIP 文件预览的引用（Label，显示选中文件的内容）。
@onready var zip_viewer_file_preview := $MarginContainer/VBoxContainer/Result/ZIPViewer/FilePreview as Label
## 错误信息显示的 Label 引用。
@onready var error_label := $MarginContainer/VBoxContainer/Result/ErrorLabel as Label

## 导出按钮的引用。
@onready var export_button := $MarginContainer/VBoxContainer/Export as Button
## 导出文件选择对话框的引用。
@onready var export_file_dialog := $MarginContainer/VBoxContainer/Export/FileDialog as FileDialog

## ZIP 读取器实例，用于读取和浏览 ZIP 压缩包内容。
var zip_reader := ZIPReader.new()

## 保存 3D 场景查看器中导入的根节点引用，以便后续导出。
var scene_viewer_root_node: Node


## 重置所有查看器的可见性，隐藏所有显示区域。
## 每次打开新文件前调用，确保界面恢复到初始状态。
func reset_visibility() -> void:
	plain_text_viewer.visible = false
	texture_viewer.visible = false
	audio_player.visible = false

	scene_viewer.visible = false
	# 获取场景查看器的最后一个子节点，如果是 3D 节点则移除并释放
	var last_child := scene_viewer.get_child(-1)
	if last_child is Node3D:
		scene_viewer.remove_child(last_child)
		last_child.queue_free()

	font_viewer.visible = false

	zip_viewer.visible = false
	zip_viewer_file_list.clear()

	error_label.visible = false
	export_button.disabled = false


## "浏览"按钮的信号回调。弹出文件选择对话框。
func _on_browse_pressed() -> void:
	file_dialog.popup_centered_ratio()


## 文件路径输入框提交文本的信号回调。
## 参数:
##   new_text: 用户输入的文件路径
func _on_file_path_text_submitted(new_text: String) -> void:
	open_file(new_text)
	# 将光标置于提交文本的末尾
	file_path_edit.caret_column = file_path_edit.text.length()


## 文件选择对话框中选中文件的信号回调。
## 参数:
##   path: 选中的文件路径
func _on_file_dialog_file_selected(path: String) -> void:
	open_file(path)


## 音频播放按钮的信号回调。点击后播放当前加载的音频。
func _on_audio_player_pressed() -> void:
	audio_stream_player.play()


## 3D 场景查看器缩放滑块值变化的信号回调。
## 参数:
##   value: 滑块的值（取负值，使滑块向左为放大，向右为缩小）
## 核心逻辑: 滑块使用负值便于反转方向（Camera3D 的 orthogonal size 越小表示放大倍数越大）。
func _on_scene_viewer_zoom_value_changed(value: float) -> void:
	# 滑块使用负值便于反转方向（Camera3D 的 orthogonal size 越小表示放大倍数越大）。
	scene_viewer_camera.size = abs(value)


## ZIP 文件列表中选中项变化的信号回调。
## 参数:
##   index: 选中项的索引
## 核心逻辑: 从 ZIP 读取器中读取选中文件的内容，以 UTF-8 文本形式显示在预览区域。
func _on_zip_viewer_item_selected(index: int) -> void:
	zip_viewer_file_preview.text = zip_reader.read_file(
			zip_viewer_file_list.get_item_text(index)
		).get_string_from_utf8()


#region 文件导出
## "导出"按钮的信号回调。弹出导出文件选择对话框。
func _on_export_pressed() -> void:
	export_file_dialog.popup_centered_ratio()


## 导出文件对话框中确认导出路径的信号回调。
## 参数:
##   path: 导出目标文件路径
## 核心逻辑: 根据当前可见的查看器类型，以对应格式导出文件。
func _on_export_file_dialog_file_selected(path: String) -> void:
	# 导出纯文本内容
	if plain_text_viewer.visible:
		var file_access := FileAccess.open(path, FileAccess.WRITE)
		file_access.store_string(plain_text_viewer_label.text)
		file_access.close()

	# 导出图片
	elif texture_viewer.visible:
		var image := texture_viewer.texture.get_image()
		if path.ends_with(".png"):
			image.save_png(path)
		if path.ends_with(".jpg") or path.ends_with(".jpeg"):
			const JPG_QUALITY = 0.9
			image.save_jpg(path, JPG_QUALITY)
		if path.ends_with(".webp"):
			# 默认以无损格式保存 WebP，但可以通过 Image.save_webp() 的可选参数改为有损格式。
			image.save_webp(path)

	# 导出音频（Ogg Vorbis 和 MP3 无法在运行时导出为标准格式）
	elif audio_player.visible:
		# Ogg Vorbis 和 MP3 音频无法在运行时导出为标准格式
		# （只有 WAV 源文件可以使用 AudioStreamWAV.save_to_wav() 保存为 WAV 格式）。
		pass

	# 导出 3D 场景为 glTF/glB 格式
	elif scene_viewer.visible:
		var gltf_document := GLTFDocument.new()
		var gltf_state := GLTFState.new()
		gltf_document.append_from_scene(scene_viewer_root_node, gltf_state)
		# 输出路径的文件扩展名（.gltf 或 .glb）决定使用文本格式还是二进制格式。
		# 二进制格式写入更快、体积更小，但不易调试。二进制格式也更适合嵌入纹理。
		gltf_document.write_to_filesystem(gltf_state, path)

	# 导出字体（无法在运行时导出为标准格式）
	elif font_viewer.visible:
		# 字体无法在运行时导出为标准格式
		# （只能使用 ResourceSaver 类保存为 Godot 特有的 .res 格式）。
		pass

	# 导出 ZIP 压缩包（重新打包为新的 ZIP 文件）
	elif zip_viewer.visible:
		var zip_packer := ZIPPacker.new()
		var error := zip_packer.open(path)
		if error != OK:
			push_error("保存 ZIP 压缩包时出错: %s" % path)
			return

		for file in zip_reader.get_files():
			zip_packer.start_file(file)
			zip_packer.write_file(zip_reader.read_file(file))
			zip_packer.close_file()

		zip_packer.close()
#endregion


## 显示错误信息。
## 参数:
##   message: 错误描述文本
## 核心逻辑: 先重置所有查看器可见性，然后显示错误标签。
func show_error(message: String) -> void:
	reset_visibility()
	error_label.text = "ERROR: %s" % message
	error_label.visible = true


## 打开并加载指定路径的文件，根据文件类型自动选择对应的查看器。
## 参数:
##   path: 要打开的文件路径
## 核心逻辑: 根据文件扩展名判断类型，使用 Godot 对应的 API 加载并显示。
func open_file(path: String) -> void:
	print_rich("Opening: [u]%s[/u]" % path)
	file_path_edit.text = path
	var path_lower := path.to_lower()

	# 图片类型处理
	if (
			path_lower.ends_with(".jpg")
			or path_lower.ends_with(".jpeg")
			or path_lower.ends_with(".png")
			or path_lower.ends_with(".webp")
			or path_lower.ends_with(".svg")
			or path_lower.ends_with(".tga")
			or path_lower.ends_with(".bmp")
	):
		# 此方法处理一切，从基于文件扩展名的格式检测到从磁盘读取文件。
		# 如果需要错误处理或更多控制（如更改 SVG 加载的缩放比例），
		# 请使用 Image 类的 load_*_from_buffer()（其中 * 是文件扩展名）
		# 和 load_svg_from_string() 方法。
		var image := Image.load_from_file(path)
		reset_visibility()
		export_file_dialog.filters = ["*.png ; PNG Image", "*.jpg, *.jpeg ; JPEG Image", "*.webp ; WebP Image"]
		texture_viewer.visible = true
		texture_viewer.texture = ImageTexture.create_from_image(image)

	# 音频类型处理
	elif path_lower.ends_with(".ogg") or path_lower.ends_with(".mp3") or path_lower.ends_with(".wav"):
		# 如果 Ogg Vorbis 数据在 PackedByteArray 中而非文件中，也可以使用 AudioStreamOggVorbis.load_from_buffer()。
		if path_lower.ends_with(".ogg"):
			audio_stream_player.stream = AudioStreamOggVorbis.load_from_file(path)
		elif path_lower.ends_with(".mp3"):
			audio_stream_player.stream = AudioStreamMP3.load_from_file(path)
		elif path_lower.ends_with(".wav"):
			audio_stream_player.stream = AudioStreamWAV.load_from_file(path)
		reset_visibility()
		export_button.disabled = true
		audio_player.visible = true
		var duration := roundi(audio_stream_player.stream.get_length())
		@warning_ignore("integer_division")
		audio_player_information.text = "Duration: %02d:%02d" % [duration / 60, duration % 60]

	# 3D 场景类型处理（glTF/glB/FBX）
	elif path_lower.ends_with(".gltf") or path_lower.ends_with(".glb") or path_lower.ends_with(".fbx"):
		# GLTFState 由 GLTFDocument 用于存储加载场景的状态。
		# GLTFDocument 是实际将 glTF 数据加载到 Godot 节点树的类，
		# 支持 glTF 功能如灯光和摄像机。
		#
		# FBX 同理，只是使用 FBXState 和 FBXDocument。
		if path_lower.ends_with(".gltf") or path_lower.ends_with(".glb"):
			var gltf_document := GLTFDocument.new()
			var gltf_state := GLTFState.new()
			var error := gltf_document.append_from_file(path, gltf_state)
			if error == OK:
				scene_viewer_root_node = gltf_document.generate_scene(gltf_state)
				reset_visibility()
				scene_viewer.add_child(scene_viewer_root_node)
				export_file_dialog.filters = ["*.gltf ; glTF Text Scene", "*.glb ; glTF Binary Scene"]
				scene_viewer.visible = true
			else:
				show_error('无法将 "%s" 加载为 glTF 场景（错误代码: %s）。' % [path.get_file(), error_string(error)])
		elif path_lower.ends_with(".fbx"):
			var fbx_document := FBXDocument.new()
			var fbx_state := FBXState.new()
			var error := fbx_document.append_from_file(path, fbx_state)
			if error == OK:
				scene_viewer_root_node = fbx_document.generate_scene(fbx_state)
				reset_visibility()
				scene_viewer.add_child(scene_viewer_root_node)
				export_file_dialog.filters = ["*.fbx ; FBX Scene"]
				scene_viewer.visible = true
			else:
				show_error('无法将 "%s" 加载为 FBX 场景（错误代码: %s）。' % [path.get_file(), error_string(error)])

	# 字体类型处理
	elif (
			path_lower.ends_with(".ttf")
			or path_lower.ends_with(".otf")
			or path_lower.ends_with(".woff")
			or path_lower.ends_with(".woff2")
			or path_lower.ends_with(".pfb")
			or path_lower.ends_with(".pfm")
			or path_lower.ends_with(".fnt")
			or path_lower.ends_with(".font")
	):
		var font_file := FontFile.new()
		if path_lower.ends_with(".fnt") or path_lower.ends_with(".font"):
			font_file.load_bitmap_font(path)
		else:
			font_file.load_dynamic_font(path)

		if not font_file.data.is_empty():
			font_viewer.add_theme_font_override(&"font", font_file)
			reset_visibility()
			font_viewer.visible = true
			export_button.disabled = true
		else:
			show_error('无法将 "%s" 加载为字体。' % path.get_file())

	# ZIP 压缩包类型处理
	elif path_lower.ends_with(".zip"):
		# 支持任何 ZIP 文件，包括 Godot 的"导出 PCK/ZIP"功能生成的文件
		# （虽然这些文件包含的是导入后的 Godot 资源而非原始项目文件）。
		#
		# 使用 ProjectSettings.load_resource_pack() 加载 Godot 导出的 PCK 或 ZIP 文件作为附加数据包。
		# 对于 DLC，推荐使用那种方式，因为它可以无缝地与附加数据包交互（虚拟文件系统）。
		zip_reader.open(path)
		var files := zip_reader.get_files()
		files.sort()
		export_file_dialog.filters = ["*.zip ; ZIP Archive"]
		reset_visibility()
		for file in files:
			zip_viewer_file_list.add_item(file, null)
			# 将文件夹项设置为禁用状态
			zip_viewer_file_list.set_item_disabled(-1, file.ends_with("/"))

		zip_viewer.visible = true

	# 其他类型（作为纯文本打开）
	else:
		# 以纯文本方式打开并显示内容（如果可能）
		var file_contents := FileAccess.get_file_as_string(path)
		if file_contents.is_empty():
			show_error("文件为空或为二进制文件。")
		else:
			plain_text_viewer_label.text = file_contents
			reset_visibility()
			plain_text_viewer.visible = true
