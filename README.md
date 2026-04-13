# Task Manager

A cross-platform Flutter task management app with JWT-authenticated REST API, full CRUD, and real-time filtering.

## Features

- **JWT auth** — login persists across sessions via `shared_preferences`
- **Task CRUD** — create, view, edit, delete tasks
- **Filtering** — filter by status (`todo` / `in_progress` / `done`) and priority (`low` / `medium` / `high`)
- **Search** — live text search across task titles
- **Due dates** — optional per-task deadline with formatted display
- **Assignment** — optional `assignedTo` field per task
- **Material 3 UI** — indigo color scheme, rounded components, clean card layout

## Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3 (Dart ≥ 3.0) |
| State | Provider + ChangeNotifier |
| HTTP | `http` package |
| Auth storage | `shared_preferences` |
| Date formatting | `intl` |
| Mock API | json-server + json-server-auth |

## Project Structure

```
task_manager/
├── lib/
│   ├── main.dart                   # App entry, Provider setup, auth-gated routing
│   ├── models/
│   │   └── task.dart               # Task model — fromJson / toJson / copyWith
│   ├── screens/
│   │   ├── login_screen.dart       # Email + password form
│   │   ├── task_list_screen.dart   # Task list with search + filter chips
│   │   ├── task_detail_screen.dart # Task detail view
│   │   └── task_form_screen.dart   # Create / edit form
│   ├── services/
│   │   ├── auth_service.dart       # Login, logout, token storage, baseUrl config
│   │   └── api_service.dart        # REST client — CRUD + query params
│   └── widgets/
│       └── task_card.dart          # Priority badge, status chip, due date row
└── mock-api/
    ├── db.json                     # json-server data store (users + tasks)
    └── package.json                # json-server-auth setup
```

## Getting Started

### 1. Start the mock API

```bash
cd mock-api
npm install
npm start
# API runs at http://localhost:3000
```

**Demo credentials:**
```
Email:    admin@admin.com
Password: admin123
```

### 2. Configure the base URL

In `lib/services/auth_service.dart`:

```dart
String get baseUrl {
  if (kIsWeb) return 'http://localhost:3000';     // Web / iOS simulator
  return 'http://10.0.2.2:3000';                  // Android emulator
  // Physical device on Wi-Fi → replace with your Mac's local IP
  // run: ipconfig getifaddr en0
}
```

### 3. Run the app

```bash
flutter pub get
flutter run
```

Supported platforms: Android, iOS, macOS, Web.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/login` | Authenticate — returns `accessToken` |
| GET | `/tasks` | List tasks (optional `?status=`, `?priority=`, `?search=`) |
| GET | `/tasks/:id` | Get single task |
| POST | `/tasks` | Create task |
| PUT | `/tasks/:id` | Update task |
| DELETE | `/tasks/:id` | Delete task |

All `/tasks` requests require `Authorization: Bearer <token>`.

## Task Model

```dart
Task({
  String id,
  String title,
  String? description,
  String status,     // 'todo' | 'in_progress' | 'done'
  String priority,   // 'low' | 'medium' | 'high'
  DateTime? dueDate,
  String? assignedUser,
})
```
