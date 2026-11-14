# AI 五子棋 Apple Watch App

## Project Type

软件开发。

## Project Knowledge

- 项目说明：`README.md`
- 游戏与 AI 核心：`Sources/GomokuCore/`
- watchOS 界面与交互：`Sources/AIGomoku/`
- xtool 配置：`xtool.yml`、`Support/Info.plist`

## Protected Areas

- 不提交 Apple 账号凭据、证书、provisioning profile、设备 UDID 或配对记录。
- 不自动修改已配对设备、系统版本或 Windows 安全设置。
- 不覆盖用户在同一目录中新增的无关文件。

## Verification Matrix

- Swift 格式：`swift-format lint --recursive Sources Tests Verification`
- 核心逻辑：编译并运行 `Verification/main.swift`
- watchOS 构建：`xtool dev build --triple arm64-apple-watchos`
- 设备安装：签名后使用 `tools/watchos/watch_device.py --install` 并检查 Watch registry
