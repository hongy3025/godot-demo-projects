# Android 应用内购买 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中实现 Android 应用内购买（IAP）"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [场景树全景](#6-场景树全景)
7. [如何扩展](#7-如何扩展)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的 Android 应用内购买演示项目。核心功能是：

> **通过 `GodotGooglePlayBilling` 插件实现 Google Play 结算服务，包括查询商品、购买、确认购买和消耗购买。**

> **注意：** 运行此演示需要将游戏导出并上传到 Google Play。

---

## 2. 快速上手

### 2.1 前提条件

1. 在 Android 导出设置中启用"Custom Build"
2. 安装并启用 `GodotGooglePlayBilling` 插件
3. 在 Google Play Console 中配置商品

### 2.2 操作说明

| 按钮 | 功能 |
|------|------|
| Query Sku Details | 查询商品详情 |
| Purchase | 发起购买 |
| Consume | 消耗已购买的商品 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│           UI 层                      │
│  按钮 / 标签 / 警告对话框           │
├──────────────────────────────────────┤
│         IAP 业务逻辑层               │
│  iap_demo.gd (GodotGooglePlayBilling)│
├──────────────────────────────────────┤
│       Google Play 结算服务           │
│  GodotGooglePlayBilling 插件         │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `iap_demo.gd` — IAP 主控制脚本 ⭐

**地位：** 项目的核心，处理所有 Google Play 结算 API 调用。

**常量：**

| 常量 | 值 | 说明 |
|------|-----|------|
| `TEST_ITEM_SKU` | `"my_in_app_purchase_sku"` | 测试商品的 SKU |

**关键变量：**

| 变量 | 说明 |
|------|------|
| `payment` | `GodotGooglePlayBilling` 单例引用 |
| `test_item_purchase_token` | 最近一次购买的 token |

**生命周期：**

```gdscript
func _ready() -> void:
    if Engine.has_singleton(&"GodotGooglePlayBilling"):
        payment = Engine.get_singleton(&"GodotGooglePlayBilling")
        # 连接所有信号
        payment.connected.connect(_on_connected)
        payment.disconnected.connect(_on_disconnected)
        # ...
        payment.startConnection()
    else:
        show_alert("Android IAP support is not enabled...")
```

**信号连接：**

| 信号 | 说明 |
|------|------|
| `connected` | 连接到 Google Play 结算服务成功 |
| `disconnected` | 连接断开 |
| `connect_error` | 连接失败 |
| `purchases_updated` | 购买状态更新 |
| `purchase_error` | 购买失败 |
| `sku_details_query_completed` | 商品详情查询完成 |
| `sku_details_query_error` | 商品详情查询失败 |
| `purchase_acknowledged` | 购买确认成功 |
| `purchase_acknowledgement_error` | 购买确认失败 |
| `purchase_consumed` | 消耗购买成功 |
| `purchase_consumption_error` | 消耗购买失败 |
| `query_purchases_response` | 查询购买记录响应 |

**购买流程：**

```gdscript
# 1. 连接
payment.startConnection()

# 2. 连接成功后查询已有购买
func _on_connected() -> void:
    payment.queryPurchases("inapp")

# 3. 查询商品详情
func _on_QuerySkuDetailsButton_pressed() -> void:
    payment.querySkuDetails([TEST_ITEM_SKU], "inapp")

# 4. 发起购买
func _on_PurchaseButton_pressed() -> void:
    var response := payment.purchase(TEST_ITEM_SKU)

# 5. 确认购买（自动处理）
func _on_purchases_updated(purchases: Array) -> void:
    for purchase in purchases:
        if not purchase.is_acknowledged:
            payment.acknowledgePurchase(purchase.purchase_token)

# 6. 消耗购买
func _on_ConsumeButton_pressed() -> void:
    payment.consumePurchase(test_item_purchase_token)
```

---

## 5. 关键概念详解

### 5.1 购买生命周期

```
查询商品 → 发起购买 → Google Play 处理
    ↓
购买成功 → 确认购买 (acknowledge)
    ↓
消耗购买 (consume) → 可再次购买
```

### 5.2 确认 vs 消耗

| 操作 | 说明 |
|------|------|
| **确认 (Acknowledge)** | 告知 Google Play 已处理购买，否则 3 天后自动退款 |
| **消耗 (Consume)** | 消耗商品，使其可以再次购买（适用于消耗品） |

### 5.3 商品类型

- `"inapp"` — 一次性商品
- `"subs"` — 订阅商品

### 5.4 插件要求

项目在 `project.godot` 中配置了 Android 模块：
```ini
[android]
modules="org/godotengine/godot/GodotPaymentV3"
```

---

## 6. 场景树全景

### 6.1 主场景 `main.tscn`

```
Main (Control)
├── Label                              ← 说明文字
├── QuerySkuDetailsButton (Button)
├── PurchaseButton (Button)
├── ConsumeButton (Button)
└── AlertDialog (AcceptDialog)         ← 提示对话框
```

---

## 7. 如何扩展

### 7.1 添加更多商品

```gdscript
const PRODUCT_SKU = "premium_upgrade"
const SUBSCRIPTION_SKU = "monthly_sub"
```

### 7.2 处理订阅

使用 `"subs"` 替代 `"inapp"`：
```gdscript
payment.queryPurchases("subs")
payment.querySkuDetails([SUBSCRIPTION_SKU], "subs")
```

### 7.3 验证购买

在服务器端验证购买 token，防止伪造购买。

---

## 推荐阅读路径

1. **`iap_demo.gd`** — 理解 IAP 的完整工作流程
2. **`project.godot`** — 查看 Android 模块配置
