# SleepHoldService

A lightweight macOS service that prevents system sleep when the lid is closed.

## System Requirements

- macOS 12+
- Administrator privileges for installation

## Installation

Run the following command in Terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Lakr233/SleepHoldService/HEAD/net_install.sh)"
```

## Third-Party Integration

This service integrates seamlessly with [Sentry](https://github.com/Lakr233/Sentry). When Sentry is activated, SleepHoldService automatically prevents sleep mode.

For developers, see `main.swift` for network request implementation. Create a session and make extend requests as needed. Call terminate when finished or let it expire naturally.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

Copyright 2025 © Lakr Aream. All rights reserved.
