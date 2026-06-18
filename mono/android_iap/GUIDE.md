# Android in-app purchases with C# - 源代码导读

> 本文档面向 Godot 新手，展示如何在 Android 平台使用 C# 实现应用内购（IAP）。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**Android in-app purchases with C#** 演示了如何在 Godot 中使用 C# 集成 Google Play 结算服务。核心组件是 `GodotGooglePlayBilling` 插件，它封装了 Android 的 `BillingClient` API。

- 语言：C#
- 主场景：`main.tscn`
- 依赖：Godot Google Play Billing 插件

---

## 2. 快速上手

**注意：** 此项目不能在编辑器中直接运行，需要导出 APK 并上传到 Google Play 控制台进行测试。

1. 在 Android 导出设置中启用 Custom Build
2. 安装并启用 GodotGooglePlayBilling 插件
3. 在 Google Play Console 中配置商品 SKU
4. 导出并上传到 Google Play 内部测试轨道

---

## 3. 核心架构

```
Main (Control)
├── GooglePlayBilling (GodotGooglePlayBilling)  ← 支付核心
├── Label                                        ← 状态显示
└── AlertDialog (AcceptDialog)                   ← 弹窗提示
```

---

## 4. 文件逐层导读

### `Main.cs` — 支付主逻辑 ⭐

`Main.cs:9` 定义了 `Main` 类，继承 `Control`，是整个项目的核心。

**初始化流程** (`_Ready` 方法，`Main.cs:20`)：
1. 获取 `GooglePlayBilling` 节点引用
2. 连接所有信号回调（Connected、Disconnected、ConnectError 等）
3. 调用 `_payment.StartConnection()` 启动连接

**信号连接示例** (`Main.cs:31-63`)：
```csharp
_payment.Connect(GooglePlayBilling.SignalName.Connected,
    Callable.From(OnConnected));
_payment.Connect(GooglePlayBilling.SignalName.PurchasesUpdated,
    Callable.From<Array>(OnPurchasesUpdated));
```

**关键回调方法：**

| 方法 | 触发时机 | 作用 |
|------|----------|------|
| `OnConnected()` | 连接成功 | 查询未确认的购买并自动确认 |
| `OnDisconnected()` | 断开连接 | 10 秒后自动重连 |
| `OnPurchasesUpdated()` | 购买更新 | 确认所有未确认的购买 |
| `OnPurchaseAcknowledged()` | 购买确认成功 | 显示确认成功消息 |
| `OnPurchaseConsumed()` | 消耗成功 | 显示消耗成功消息 |

**UI 按钮回调** (`Main.cs:177-200`)：
- `OnQuerySkuDetailsButton_pressed()` — 查询商品详情
- `OnPurchaseButton_pressed()` — 发起购买
- `OnConsumeButton_pressed()` — 消耗已购买的商品

---

## 5. 关键概念详解

### 5.1 Google Play Billing 流程

```
1. StartConnection() → 连接到 Google Play
2. QuerySkuDetails() → 查询商品信息
3. Purchase() → 发起购买（弹出 Google 支付界面）
4. 用户完成支付 → PurchasesUpdated 信号触发
5. AcknowledgePurchase() → 确认购买（必须！否则 3 天后退款）
6. ConsumePurchase() → 消耗商品（可重复购买的商品需要）
```

### 5.2 购买确认的重要性

Google Play 要求所有购买必须在 3 天内确认，否则自动退款。项目在 `OnConnected()` 和 `OnPurchasesUpdated()` 中都会检查并确认未确认的购买。

### 5.3 断线重连

`OnDisconnected()` 中设置 10 秒定时器自动重连，确保支付服务在意外断开后能恢复。
