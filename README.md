<div align="center">

# 🎯 Flutter Focus Flow

**A minimalist productivity timer for deep work — built with Flutter.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://flutter.dev)

</div>

---

## Overview

Focus Flow is a distraction-free Pomodoro-style timer app. It helps you enter deep work sessions using timed intervals, with gentle transitions to keep you in a flow state.

## Features

- ⏱️ **Configurable Pomodoro intervals** (work / short break / long break)
- 🔔 **Native notifications** when a session ends
- 🌙 **Dark mode** by default
- 📊 **Session history** — track your daily focus streaks
- 🎨 **Minimal UI** — no clutter, just your timer

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3 |
| State | Provider / Riverpod |
| Local Storage | Hive |
| Notifications | flutter_local_notifications |
| Splash | flutter_native_splash |

## Getting Started

```bash
git clone https://github.com/ayyushnegii/flutter-focus-flow.git
cd flutter-focus-flow
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── screens/       # Timer, History, Settings
├── widgets/       # Reusable UI components
├── providers/     # State management
└── models/        # Session data models
```

## Contributing

PRs welcome. Please open an issue first to discuss major changes.

## License

MIT © [Ayush Negi](https://github.com/ayyushnegii)
