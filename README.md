# Live Screen Timer

An Android app that tracks how long your screen has been on since the last unlock, displayed as a persistent notification.

## Features

- Persistent notification showing time since last screen unlock (`0h 0m 0s`)
- Automatically resets when the screen goes dark
- Starts fresh on every unlock
- Runs on device startup — no need to open the app
- Themed in orange, gold, and red

## How it works

The app runs a native Android foreground service (`ScreenTimerService`) that registers a broadcast receiver at runtime for `SCREEN_OFF` and `USER_PRESENT` events. When the screen turns off the notification is dismissed; when the screen is unlocked a new notification appears and starts counting from zero.

## Setup

To set a custom app icon, drop a square PNG (1024×1024 recommended) at `assets/icon.png` and run:
```bash
flutter pub run flutter_launcher_icons
```

Run on device:
```bash
flutter run
```

## Requirements

- Flutter 3.x+
- Android 8.0 (API 26) or higher
- Notification permission (prompted on first launch)
