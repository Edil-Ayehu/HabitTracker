# 📖 Habit Tracker

A modern **Habit Tracker** built with **SwiftUI** and **SwiftData**, designed to help users build consistent habits through daily tracking, reminders, statistics, streaks, and motivational quotes.

<p align="center">
  <img src="https://github.com/user-attachments/assets/e6dab593-408a-435e-a8ff-52035fcea0c1" width="250">
  <img src="https://github.com/user-attachments/assets/9517b51f-4b3f-4e51-9ea9-f3d393f2eaf6" width="250">
  <img src="https://github.com/user-attachments/assets/83bed7d9-2711-48da-b212-6f8e1e17dba2" width="250">
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

<img src="https://github.com/user-attachments/assets/e6dab593-408a-435e-a8ff-52035fcea0c1" width="300">
---

## Create Habit

<img src="https://github.com/user-attachments/assets/346d997a-9d2e-434d-be1f-dfcf53d36b53" width="300">

---

## Habit Details

<img src="https://github.com/user-attachments/assets/9517b51f-4b3f-4e51-9ea9-f3d393f2eaf6" width="300">

---

## Statistics

 <img src="https://github.com/user-attachments/assets/83bed7d9-2711-48da-b212-6f8e1e17dba2" width="300">

---

## Notification Settings

<img src="https://github.com/user-attachments/assets/34aa7d9a-9831-438d-9291-eb97588d7431" width="300">

---

## Settings

<img src="https://github.com/user-attachments/assets/492db84b-afa7-4cca-900e-2c4f73db385c" width="300">

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

<p align="center">
  <img src="https://github.com/user-attachments/assets/e6dab593-408a-435e-a8ff-52035fcea0c1" width="230">
  <img src="https://github.com/user-attachments/assets/9517b51f-4b3f-4e51-9ea9-f3d393f2eaf6" width="230">
  <img src="https://github.com/user-attachments/assets/83bed7d9-2711-48da-b212-6f8e1e17dba2" width="230">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/34aa7d9a-9831-438d-9291-eb97588d7431" width="230">
  <img src="https://github.com/user-attachments/assets/346d997a-9d2e-434d-be1f-dfcf53d36b53" width="230">
  <img src="https://github.com/user-attachments/assets/492db84b-afa7-4cca-900e-2c4f73db385c" width="230">
</p>

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

GitHub: https://github.com/Edil-Ayehu

LinkedIn: www.linkedin.com/in/edilayehu-tadesse-mobile-dev-expert

---

# ⭐ Support

If you found this project useful, consider giving it a ⭐ on GitHub!
