## AI 对手战斗者 —— 自动行动的 Combatant。
## 激活后使用计时器延迟执行攻击。
extends Combatant

## 设置激活状态：激活后自动开始攻击计时。
func set_active(value: bool) -> void:
	super.set_active(value)
	if not active:
		return

	if not $Timer.is_inside_tree():
		return

	# 启动计时器，超时后自动攻击玩家
	$Timer.start()
	await $Timer.timeout

	# 查找对手（父节点中不是自己的子节点）
	var target: Node
	for actor in get_parent().get_children():
		if not actor == self:
			target = actor
			break

	attack(target)
