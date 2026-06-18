## Android 内购（IAP）演示脚本 —— 展示 Google Play 结算集成。
##
## 该脚本继承自 [Control]，演示如何使用 GodotGooglePlayBilling 插件实现
## Android 应用内购功能，包括连接、查询商品、购买、确认和消耗商品。
extends Control

## 测试商品的 SKU（商品 ID），需在 Google Play Console 中配置。
const TEST_ITEM_SKU = "my_in_app_purchase_sku"

## 弹窗对话框节点，用于显示提示信息。
@onready var alert_dialog: AcceptDialog = $AlertDialog
## 标签节点，用于显示状态信息。
@onready var label: Label = $Label

## Google Play 结算插件单例的引用。
var payment: Object = null
## 最近一次购买的测试商品的购买令牌（purchase token），用于确认和消耗操作。
var test_item_purchase_token: String = ""


## 节点就绪 —— 初始化 Google Play 结算连接。
##
## 功能：检查 GodotGooglePlayBilling 插件是否可用，如果可用则连接所有信号并启动连接。
## 如果插件不可用，显示提示信息并禁用相关按钮。
## 参数：无
## 返回值：无
func _ready() -> void:
	if Engine.has_singleton(&"GodotGooglePlayBilling"):
		label.text += "\n\n\nTest item SKU: %s" % TEST_ITEM_SKU

		payment = Engine.get_singleton(&"GodotGooglePlayBilling")
		# 连接成功信号，无参数
		payment.connected.connect(_on_connected)
		# 断开连接信号，无参数
		payment.disconnected.connect(_on_disconnected)
		# 连接错误信号，参数：响应 ID（int）、调试信息（string）
		payment.connect_error.connect(_on_connect_error)
		# 购买更新信号，参数：购买列表（Dictionary[]）
		payment.purchases_updated.connect(_on_purchases_updated)
		# 购买错误信号，参数：响应 ID（int）、调试信息（string）
		payment.purchase_error.connect(_on_purchase_error)
		# SKU 详情查询完成信号，参数：SKU 详情列表（Dictionary[]）
		payment.sku_details_query_completed.connect(_on_sku_details_query_completed)
		# SKU 详情查询错误信号，参数：响应 ID（int）、调试信息（string）、查询的 SKU 列表（string[]）
		payment.sku_details_query_error.connect(_on_sku_details_query_error)
		# 购买确认成功信号，参数：购买令牌（string）
		payment.purchase_acknowledged.connect(_on_purchase_acknowledged)
		# 购买确认错误信号，参数：响应 ID（int）、调试信息（string）、购买令牌（string）
		payment.purchase_acknowledgement_error.connect(_on_purchase_acknowledgement_error)
		# 商品消耗成功信号，参数：购买令牌（string）
		payment.purchase_consumed.connect(_on_purchase_consumed)
		# 商品消耗错误信号，参数：响应 ID（int）、调试信息（string）、购买令牌（string）
		payment.purchase_consumption_error.connect(_on_purchase_consumption_error)
		# 查询购买结果信号，参数：购买列表（Dictionary[]）
		payment.query_purchases_response.connect(_on_query_purchases_response)
		payment.startConnection()
	else:
		show_alert('Android IAP support is not enabled.\n\nMake sure you have enabled "Custom Build" and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings!\nThis application will not work otherwise.')


## 显示弹窗提示。
##
## 功能：设置弹窗对话框的文本并弹出，同时禁用所有操作按钮。
## 参数：
##   text: 要显示的提示文本（String）
## 返回值：无
func show_alert(text: String) -> void:
	alert_dialog.dialog_text = text
	alert_dialog.popup_centered_clamped(Vector2i(600, 0))
	$QuerySkuDetailsButton.disabled = true
	$PurchaseButton.disabled = true
	$ConsumeButton.disabled = true


## 连接成功回调 —— 查询已有购买记录。
##
## 功能：连接成功后查询应用内商品（非订阅）的购买记录，
## 用于确认和处理尚未确认的购买。
## 参数：无
## 返回值：无
func _on_connected() -> void:
	print("PurchaseManager connected")
	# 查询应用内商品购买记录，"subs" 用于查询订阅商品
	payment.queryPurchases("inapp")


## 查询购买记录结果回调 —— 确认所有未确认的购买。
##
## 功能：遍历查询到的购买记录，对尚未确认的购买执行确认操作。
## 参数：
##   query_result: 查询结果字典，包含 status、purchases、response_code、debug_message 等字段
## 返回值：无
func _on_query_purchases_response(query_result: Dictionary) -> void:
	if query_result.status == OK:
		for purchase: Dictionary in query_result.purchases:
			# 所有购买必须确认，详见 Android 开发者文档
			# https://developer.android.com/google/play/billing/integrate#process
			if not purchase.is_acknowledged:
				print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
				payment.acknowledgePurchase(purchase.purchase_token)
	else:
		print("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)


## SKU 详情查询完成回调 —— 显示商品详情。
##
## 功能：查询到商品详情后，以弹窗形式显示第一个商品的 JSON 信息。
## 参数：
##   sku_details: SKU 详情数组（Array），每个元素是一个包含商品信息的字典
## 返回值：无
func _on_sku_details_query_completed(sku_details: Array) -> void:
	for available_sku: Dictionary in sku_details:
		show_alert(JSON.stringify(available_sku))


## 购买更新回调 —— 处理新完成的购买。
##
## 功能：当有新的购买完成时，遍历购买列表确认所有未确认的购买，
## 并记录最后一个购买的令牌用于后续消耗操作。
## 参数：
##   purchases: 购买列表（Array），每个元素是一个购买信息字典
## 返回值：无
func _on_purchases_updated(purchases: Array) -> void:
	print("Purchases updated: %s" % JSON.stringify(purchases))

	# 参考 `_on_connected()` 中的逻辑
	for purchase: Dictionary in purchases:
		if not purchase.is_acknowledged:
			print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
			payment.acknowledgePurchase(purchase.purchase_token)

	if not purchases.is_empty():
		test_item_purchase_token = purchases[purchases.size() - 1].purchase_token


## 购买确认成功回调。
func _on_purchase_acknowledged(purchase_token: String) -> void:
	print("Purchase acknowledged: %s" % purchase_token)


## 商品消耗成功回调 —— 显示消耗成功提示。
func _on_purchase_consumed(purchase_token: String) -> void:
	show_alert("Purchase consumed successfully: %s" % purchase_token)


## 连接错误回调 —— 显示错误信息。
func _on_connect_error(code: int, message: String) -> void:
	show_alert("Connect error %d: %s" % [code, message])


## 购买错误回调 —— 显示错误信息。
func _on_purchase_error(code: int, message: String) -> void:
	show_alert("Purchase error %d: %s" % [code, message])


## 购买确认错误回调 —— 显示错误信息。
func _on_purchase_acknowledgement_error(code: int, message: String) -> void:
	show_alert("Purchase acknowledgement error %d: %s" % [code, message])


## 商品消耗错误回调 —— 显示错误信息。
func _on_purchase_consumption_error(code: int, message: String, purchase_token: String) -> void:
	show_alert("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])


## SKU 详情查询错误回调 —— 显示错误信息。
func _on_sku_details_query_error(code: int, message: String) -> void:
	show_alert("SKU details query error %d: %s" % [code, message])


## 断开连接回调 —— 尝试重新连接。
##
## 功能：连接断开后等待 10 秒，然后自动重新连接。
## 参数：无
## 返回值：无
func _on_disconnected() -> void:
	show_alert("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	await get_tree().create_timer(10).timeout
	payment.startConnection()


# GUI 按钮回调函数

## 查询商品详情按钮点击回调。
##
## 功能：查询测试商品的 SKU 详情。
## 参数：无
## 返回值：无
func _on_QuerySkuDetailsButton_pressed() -> void:
	# 查询应用内商品详情，"subs" 用于查询订阅商品
	payment.querySkuDetails([TEST_ITEM_SKU], "inapp")


## 购买按钮点击回调。
##
## 功能：发起测试商品的购买请求。
## 参数：无
## 返回值：无
func _on_PurchaseButton_pressed() -> void:
	var response: Dictionary = payment.purchase(TEST_ITEM_SKU)
	if response.status != OK:
		show_alert("Purchase error %s: %s" % [response.response_code, response.debug_message])


## 消耗商品按钮点击回调。
##
## 功能：消耗最近一次购买的测试商品，使其可以再次购买。
## 参数：无
## 返回值：无
func _on_ConsumeButton_pressed() -> void:
	if test_item_purchase_token == null:
		show_alert("You need to set 'test_item_purchase_token' first! (either by hand or in code)")
		return

	payment.consumePurchase(test_item_purchase_token)
