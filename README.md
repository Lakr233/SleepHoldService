# SleepHoldService

<p align="center">
  <a href="README.md">English</a> |
  <a href="./i18n/zh-Hans/README.md">简体中文</a>
</p>

A lightweight macOS service that prevents system sleep when the lid is closed.

## System Requirements

- macOS 12+
- Administrator privileges for installation

## Installation

Run the following command in Terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Lakr233/SleepHoldService/HEAD/net_install.sh)"
```

## Uninstallation

To remove SleepHoldService from your system, run:

```bash
# Stop and unload the service
sudo launchctl unload /Library/LaunchDaemons/launched.sleepholdservice.plist

# Remove files
sudo rm -f /Library/LaunchDaemons/launched.sleepholdservice.plist
sudo rm -f /usr/local/sbin/SleepHoldService

# Re-enable sleep mode manually
sudo pmset -a disablesleep 0
```

## Third-Party Integration

This service integrates seamlessly with [Sentry](https://github.com/Lakr233/Sentry). When Sentry is activated, SleepHoldService automatically prevents sleep mode.

For developers, see `main.swift` for network request implementation. Create a session and make extend requests as needed. Call terminate when finished or let it expire naturally.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

Copyright 2025 © Lakr Aream. All rights reserved.
