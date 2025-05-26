# SleepHoldService - 不准睡觉！

<p align="center">
  <a href="../../README.md">English</a> |
  <a href="README.md">简体中文</a>
</p>

一个轻量级的 macOS 服务，在合盖时阻止系统进入睡眠状态。

## 系统要求

- macOS 12+
- 安装时需要管理员权限

## 安装

在终端中运行以下命令：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Lakr233/SleepHoldService/HEAD/net_install.sh)"
```

## 卸载

要从系统中移除 SleepHoldService，请运行：

```bash
# 停止并卸载服务
sudo launchctl unload /Library/LaunchDaemons/launched.sleepholdservice.plist

# 删除文件
sudo rm -f /Library/LaunchDaemons/launched.sleepholdservice.plist
sudo rm -f /usr/local/sbin/SleepHoldService

# 手动重新启用睡眠模式
sudo pmset -a disablesleep 0
```

## 第三方集成

该服务与 [Sentry](https://github.com/Lakr233/Sentry) 无缝集成。当 Sentry 激活时，SleepHoldService 会自动阻止睡眠模式。

对于开发者，请参阅 `main.swift` 了解网络请求实现。创建会话并根据需要发出延长请求。完成后调用终止或让其自然过期。

## 许可证

该项目采用 MIT 许可证。详情请参阅 LICENSE 文件。

---

版权所有 2025 © Lakr Aream。保留所有权利。
