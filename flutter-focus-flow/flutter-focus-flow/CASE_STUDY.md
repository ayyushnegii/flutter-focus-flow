# Focus Flow - Case Study

## Problem Statement
Existing Pomodoro and task management apps suffer from:
- Overly complex UIs that distract from focus
- Poor dark mode implementations (low contrast, harsh colors)
- Disconnected timer and task tracking workflows
- Lack of offline-first, lightweight solutions

Focus Flow solves this by combining a distraction-free Pomodoro timer with a minimal task manager, wrapped in a polished dark neon UI optimized for low-light work sessions.

## Design Decisions
1. **Dark Neon Theme**: Deep black background (#0A0A0F) with neon cyan (#00F5FF), purple (#9D00FF), and blue (#0066FF) accents to reduce eye strain during long focus sessions.
2. **Bottom Navigation**: 3-tab structure (Timer, Tasks, Stats) for thumb-friendly access.
3. **Pomodoro Logic**: Default 25min work / 5min short break / 15min long break cycles, auto-advancing between phases.
4. **Local-First Storage**: Uses `shared_preferences` and `hive_flutter` for zero-latency offline use - no accounts or cloud sync needed.
5. **Lightweight State**: `flutter_hooks` for predictable state management without boilerplate.
6. **Progress Visualization**: Circular percent indicators for timer progress, stat cards for focus metrics.

## Key Features
- ✅ Auto-cycling Pomodoro phases with session tracking
- ✅ Swipe-to-delete and toggle-complete task management
- ✅ Persistent storage for tasks and focus stats
- ✅ Clean neon UI with haptic-like visual feedback
- ✅ Stats dashboard showing total pomodoros, focus minutes, and completed tasks

## App Structure
```
lib/
├── main.dart           # App entry, bottom nav, hive init
├── theme/
│   └── app_theme.dart # Dark neon color scheme
└── screens/
    ├── timer_screen.dart   # Pomodoro timer with phase logic
    ├── tasks_screen.dart   # Task CRUD with local storage
    └── stats_screen.dart  # Focus metrics dashboard
```

## Final UI Description (Screenshots to be added)
1. **Timer Screen**: Large circular timer with neon progress ring, phase labels (WORK/SHORT BREAK/LONG BREAK), play/pause/reset controls, pomodoro count badge.
2. **Tasks Screen**: Dark input field with neon add button, dismissible task cards with checkbox toggles, line-through styling for completed tasks.
3. **Stats Screen**: Neon-accented stat cards showing total pomodoros, completed tasks, focus minutes, and daily streak tips.

## Setup Instructions
1. Clone repo: `git clone https://github.com/ayyushnegii/flutter-focus-flow.git`
2. Install dependencies: `flutter pub get`
3. Run on device/emulator: `flutter run`

## Future Improvements
- Add haptic feedback for timer completion
- Daily/weekly focus streak tracking
- Customizable Pomodoro durations
- Export focus reports as CSV
- Ambient background sounds for focus sessions