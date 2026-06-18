## 全局场景切换管理器 —— 演示不使用 SceneTree 内置方法手动切换场景。
## 继承自 [Node]，作为 autoload（自动加载）单例运行。
## 核心思路：使用 call_deferred() 延迟执行场景切换，避免在信号回调中直接删除当前场景导致崩溃。
## 通常场景切换使用 `change_scene_to_file()` 和 `change_scene_to_packed()` 方法更简单，
## 此脚本演示了不使用这些辅助方法的底层实现方式。
extends Node
# 场景切换最简便的方式是使用 SceneTree 的 `change_scene_to_file()` 和
# `change_scene_to_packed()` 方法。此脚本演示了不使用这些辅助方法时如何切换场景。


## 跳转到指定场景的入口函数。
## 参数:
##   path: 目标场景的文件路径（如 "res://scene_b.tscn"）
## 核心逻辑: 使用 call_deferred() 延迟执行实际切换，避免在信号回调中直接删除当前场景。
## 因为如果当前场景正在执行回调函数时被删除，可能导致崩溃或意外行为。
func goto_scene(path: String) -> void:
	# 此函数通常从信号回调或当前场景的其他函数中调用。
	# 此时直接删除当前场景可能是个坏主意，因为当前场景可能正在执行回调函数。
	# 最坏情况会导致崩溃或意外行为。

	# 解决方案是将加载延迟到稍后时间，确保当前场景没有代码在运行：
	_deferred_goto_scene.call_deferred(path)


## 实际执行场景切换的延迟函数（通过 call_deferred 调用）。
## 参数:
##   path: 目标场景的文件路径
## 核心逻辑: 先释放当前场景，再用 ResourceLoader 加载新场景并添加到场景树。
func _deferred_goto_scene(path: String) -> void:
	# 立即释放当前场景。因为此方法的调用已经通过 call_deferred 延迟执行，所以没有风险。
	get_tree().current_scene.free()

	var packed_scene: PackedScene = ResourceLoader.load(path)

	var instanced_scene := packed_scene.instantiate()

	# 将新场景添加到场景树中，作为根节点的直接子节点
	get_tree().root.add_child(instanced_scene)

	# 在将新场景添加到场景树后，才将其设置为当前场景
	get_tree().current_scene = instanced_scene
