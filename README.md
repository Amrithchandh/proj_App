# 📅 Routine Tracker App

A **Flutter-based mobile/desktop application** that helps students organize their daily routines, track task completion, build streaks, and stay motivated — all stored **100% offline** on the device.


---

## 🧠 What This App Does

The app targets **students** who want to:
- Plan their day by adding custom routines (e.g., study, exercise, reading)
- See daily completion progress through a visual arc gauge
- Navigate a weekly calendar to track which days they stayed on track
- Stay motivated through a dedicated motivation screen
- Customize their profile (name, avatar)

---

## 🏗️ Project Architecture

This is a **Flutter** project using the **Provider** pattern for state management and **SQLite** for local data storage. There is also a small **Node.js backend** included for a web-based database viewer.

```
ictak/
├── lib/                        # All Flutter (Dart) source code
│   ├── main.dart               # Entry point — sets up providers and routes
│   ├── models/                 # Data classes (plain Dart objects)
│   │   ├── routine.dart        # Routine model (id, title, time, isDone, etc.)
│   │   └── user_profile.dart   # User profile model (name, avatar path)
│   ├── screens/                # Full-page UI screens
│   │   ├── home_screen.dart        # Main dashboard (arc progress, calendar, routine list)
│   │   ├── add_routine_screen.dart # Form to create a new routine
│   │   ├── login_screen.dart       # User login/onboarding screen
│   │   ├── settings_screen.dart    # Profile & app settings
│   │   └── motivation_screen.dart  # Motivational quotes / content
│   ├── services/               # Business logic, database, storage
│   │   ├── database_helper.dart    # SQLite CRUD operations (add/get/delete routines)
│   │   └── storage_service.dart    # SharedPreferences for user profile & settings
│   ├── providers/              # State management (Provider pattern)
│   └── widgets/                # Reusable UI components
├── backend/                    # Node.js server (optional — for DB web viewer)
│   ├── server.js               # Express server exposing SQLite data via REST
│   ├── database.js             # Database connection for backend
│   └── db-viewer.html          # Browser UI to inspect the SQLite database
├── android/                    # Android platform-specific files
├── windows/                    # Windows platform-specific files
├── web/                        # Web platform-specific files
├── pubspec.yaml                # Flutter dependencies
└── README.md                   # This file
```

---

## 🔧 Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter (Dart) | Cross-platform UI (Android, Windows, Web) |
| State Management | Provider (`^6.1.2`) | Reactive data flow across screens |
| Local Database | SQLite via `sqflite` | Offline routine storage |
| Preferences | `shared_preferences` | User profile, settings persistence |
| Image Picking | `image_picker` | Profile avatar selection |
| Networking | `http` | Optional API calls |
| Backend (optional) | Node.js + Express | Web-based database viewer |

---

## 📱 Screens Explained

### 1. Login Screen (`login_screen.dart`)
- First screen shown to new users
- Collects the user's name and sets up their profile
- Saves profile to `SharedPreferences` for persistence

### 2. Home Screen (`home_screen.dart`)
- The main dashboard — most complex screen
- Shows an **arc (semicircular) progress indicator** of daily completion %
- Has a **7-day weekly calendar row** to navigate and track days
- Lists all routines for the selected day with checkboxes
- Routines are fetched from the SQLite database

### 3. Add Routine Screen (`add_routine_screen.dart`)
- Form to create a new routine
- User selects title, category, time, days of week, and color
- Saves routine to the SQLite database via `DatabaseHelper`

### 4. Settings Screen (`settings_screen.dart`)
- Displays and edits user profile (name, avatar)
- Avatar can be picked from the device gallery using `image_picker`
- Settings like notifications, theme preferences

### 5. Motivation Screen (`motivation_screen.dart`)
- Shows motivational quotes or tips
- Designed to boost user engagement and habit formation

---

## 🗄️ Data Storage

### SQLite Database (`database_helper.dart`)
All routines are stored locally in an SQLite database using the `sqflite` package.

**Routines Table schema:**
| Column | Type | Description |
|---|---|---|
| `id` | INTEGER (PK) | Auto-incremented unique ID |
| `title` | TEXT | Name of the routine |
| `time` | TEXT | Scheduled time (e.g., "08:00 AM") |
| `category` | TEXT | Category tag (e.g., Study, Health) |
| `color` | INTEGER | Color value for UI display |
| `days` | TEXT | JSON-encoded list of days |
| `isDone` | INTEGER | 0 = not done, 1 = completed |
| `date` | TEXT | ISO date string |

### SharedPreferences (`storage_service.dart`)
Used for lightweight key-value storage:
- User name
- Profile avatar file path
- App settings

---

## 🌐 Backend (Optional — DB Viewer)

The `backend/` folder contains a small **Node.js + Express** server that lets you inspect the SQLite database from a browser. This is useful during development.

```bash
cd backend
npm install
node server.js
# Then open http://localhost:3000/db-viewer.html in a browser
```

> This is **not required** for the Flutter app to work. The app runs fully offline.

---

## 🚀 How to Run the App

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- Android Studio or VS Code with Flutter plugin
- A connected Android device or emulator (or Windows desktop)

### Steps

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd ictak

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

To target a specific platform:
```bash
flutter run -d android     # Android device/emulator
flutter run -d windows     # Windows desktop
flutter run -d chrome      # Web browser
```

---

## 📦 Key Dependencies

```yaml
sqflite: ^2.4.1          # SQLite database for offline storage
shared_preferences: ^2.5.5  # Lightweight key-value storage
provider: ^6.1.2         # State management
image_picker: ^1.1.2     # Profile photo selection
http: ^1.2.1             # HTTP requests
cupertino_icons: ^1.0.8  # iOS-style icons
```

---

## 🙋 For New Contributors

If you're picking this up for the first time, follow this reading order:

1. Start with `lib/main.dart` — understand routing and provider setup
2. Read `lib/models/routine.dart` — understand the core data structure
3. Read `lib/services/database_helper.dart` — understand how data is saved/loaded
4. Explore `lib/screens/home_screen.dart` — the most important UI screen
5. Look at `lib/screens/add_routine_screen.dart` — how new data is created

---

## 📝 License

This project is for educational/personal use as part of an ICTAK training project.
