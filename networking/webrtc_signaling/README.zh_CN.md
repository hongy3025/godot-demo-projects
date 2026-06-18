# 用于 WebRTC 的 WebSocket 信令服务器/客户端

本示例分为 4 个部分：

- `server` 文件夹包含用 GDScript 编写的信令服务器实现（因此可以由运行 Godot 的游戏服务器运行）
- `server_node` 文件夹包含用 Node.js 编写的信令服务器实现（如果你不打算运行游戏服务器，只做匹配）。
- `client` 部分包含 GDScript 编写的客户端实现。
  - 其本身分为原始协议和 `WebRTCMultiplayer` 处理。
- `demo` 包含一个使用它的小应用程序。

**注意**：你必须在项目文件夹中解压 [最新版本](https://github.com/godotengine/webrtc-native/releases) 的 WebRTC GDExtension 插件才能在桌面端运行。

语言：GDScript

渲染器：Compatibility

## 协议

该协议基于 JSON，使用以下格式的消息：

```
{
  "id": "number",
  "type": "number",
  "data": "string",
}
```

其中 `type` 是消息类型，`id` 是已连接的对等端或 `0`，`data` 是消息特定的数据。

消息如下：

- `0 = JOIN`，客户端连接后必须立即发送，以获取分配的厅或加入已知的厅（通过 `data` 字段）。
  服务器也会将此消息发送回客户端，以通知分配的厅或成功加入。
- `1 = ID`，由服务器发送，用于在客户端加入房间时标识客户端（`id` 字段将包含分配的 ID）。
- `2 = PEER_CONNECT`，由服务器发送，用于通知同一厅中的新对等端（`id` 字段将包含新对等端的 ID）。
- `3 = PEER_DISCONNECT`，由服务器发送，用于通知同一厅中的对等端断开连接（`id` 字段将包含断开连接的对等端的 ID）。
- `4 = OFFER`，由客户端在创建 WebRTC offer 时发送，然后由服务器转发给目标对等端。
- `5 = ANSWER`，由客户端在创建 WebRTC answer 时发送，然后由服务器转发给目标对等端。
- `6 = CANDIDATE`，由客户端在生成新的 WebRTC candidate 时发送，然后由服务器转发给目标对等端。
- `7 = SEAL`，由客户端发送以密封厅（只有创建厅的客户端才能密封厅），然后由服务器返回以通知成功。
  当厅被密封后，新客户端将无法加入，并且厅将在 10 秒后被销毁（客户端断开连接）。

对于中继消息（即 `OFFER`、`ANSWER` 和 `CANDIDATE`），客户端将 `id` 字段设置为目标对等端，然后服务器将其替换为发送对等端的 ID，并发送到正确的目标。

## 截图

![截图](screenshots/screenshot.png)
