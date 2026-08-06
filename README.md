# 📖 Habit Tracker

A modern **Habit Tracker** built with **SwiftUI** and **SwiftData**, designed to help users build consistent habits through daily tracking, reminders, statistics, streaks, and motivational quotes.

<p align="center">
  <img src="Screenshots/home.png" width="250">
  <img src="Screenshots/detail.png" width="250">
  <img src="Screenshots/statistics.png" width="250">
</p>

---

# ✨ Features

### 🏠 Home Dashboard
- Personalized greeting
- Today's progress
- Completion percentage
- Current streak
- Daily habit list
- Empty state when no habits exist

---

### ✅ Habit Management

- Create habits
- Edit habits
- Delete habits
- Binary habits
- Measurable habits (Drink 8 glasses, Read 20 pages, etc.)
- Custom colors
- Custom icons
- Daily frequency support

---

### 📈 Progress Tracking

- Progress ring
- Increment / decrement measurable habits
- Mark habits as complete
- Daily completion tracking
- History view
- Calendar view

---

### 🔥 Streak System

Automatically calculates:

- Current streak
- Completion rate
- Total completed habits
- Daily progress

---

### 📊 Statistics Dashboard

Built using **Swift Charts**

Includes:

- Weekly completion chart
- Habit completion comparison
- Completion percentage
- Total habits
- Current streak

---

### 🔔 Smart Notifications

Per-habit reminders

Features:

- Enable/Disable reminders
- Custom reminder time
- Automatic reminder rescheduling
- Completed habits won't trigger reminders
- Global notification settings
- Permission management

---

### 🎨 Themes

Supports:

- Light Mode
- Dark Mode
- System Theme

---

### 💬 Motivational Quotes

When all habits for the day are completed:

- Random motivational quote
- Only displayed once per day
- Different quote every successful day

---

### 📝 Habit Notes

After completing a habit users can:

- Write a daily reflection
- Save notes
- Review notes from previous days
- Build a habit journal over time

---

# 📱 Screens

## Home

<img src="Screenshots/home.png" width="300">

---

## Create Habit

<img src="Screenshots/create_habit.png" width="300">

---

## Habit Details

<img src="Screenshots/detail.png" width="300">

---

## Statistics

<img src="Screenshots/statistics.png" width="300">

---

## Notification Settings

<img src="Screenshots/notifications.png" width="300">

---

## Settings

<img src="Screenshots/settings.png" width="300">

---

# 🏗 Architecture

The project follows **Clean Architecture** with **MVVM**.

```
Presentation
│
├── Views
├── Components
├── ViewModels
│
Domain
│
├── Entities
├── UseCases
├── Repository Protocols
│
Data
│
├── Repository Implementations
├── SwiftData
│
Core
│
├── DIContainer
├── NotificationManager
├── ThemeManager
├── Router
```

---

# 🧰 Technologies

- SwiftUI
- SwiftData
- Swift Charts
- MVVM
- Clean Architecture
- UserNotifications
- AppStorage
- Dependency Injection
- NavigationStack

---

# 📂 Project Structure

```
HabitTracker
│
├── App
├── Core
│   ├── DI
│   ├── Theme
│   ├── Notifications
│   └── Router
│
├── Domain
│   ├── Models
│   ├── Repository
│   └── UseCases
│
├── Data
│   ├── RepositoryImpl
│   └── SwiftData
│
├── Presentation
│   ├── Home
│   ├── Habit Detail
│   ├── Create Habit
│   ├── Statistics
│   ├── Settings
│   └── Components
│
└── Resources
```

---

# 🚀 Getting Started

## Clone

```bash
git clone https://github.com/yourusername/HabitTracker.git
```

---

## Open

```text
HabitTracker.xcodeproj
```

or

```text
HabitTracker.xcworkspace
```

---

## Requirements

- Xcode 16+
- iOS 18+
- Swift 6
- macOS Sonoma or later

---

# 📸 Screenshots

| Home | Habit Detail |
|------|--------------|
| ![](Screenshots/home.png) | ![](Screenshots/detail.png) |

| Statistics | Notifications |
|------------|---------------|
| ![](Screenshots/statistics.png) | ![](Screenshots/notifications.png) |

| Create Habit | Settings |
|--------------|----------|
| ![](Screenshots/create_habit.png) | ![](Screenshots/settings.png) |

---

# 🌟 Future Improvements

- Apple Watch companion app
- Widgets
- iCloud sync
- HealthKit integration
- Focus Mode support
- Habit categories
- Monthly statistics
- Achievement badges
- CSV/PDF export
- Backup & restore
- Multiple reminder schedules
- Habit sharing
- Face ID / Touch ID lock
- Localization

---

# 👨‍💻 Author

**Edilayehu Tadesse**

Mobile Engineer specializing in:

- SwiftUI
- Flutter
- Clean Architecture
- Mobile UI/UX
- Backend Development

GitHub: https://github.com/yourusername

LinkedIn: https://linkedin.com/in/yourprofile

---

# ⭐ Support

If you found this project useful, consider giving it a ⭐ on GitHub!
