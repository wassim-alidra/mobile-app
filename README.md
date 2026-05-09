# AgriGov Transporter — Flutter Mobile App

A premium Flutter mobile application for **transporters** on the AgriGov platform. Connects to the same Django backend as the web app using JWT authentication.

---

## 📁 Project Structure

```
mobile-app/
├── lib/
│   ├── main.dart                        # App entry point
│   ├── core/
│   │   ├── constants/app_constants.dart # API URLs & keys
│   │   ├── services/api_service.dart    # HTTP layer (JWT)
│   │   ├── router/app_router.dart       # GoRouter navigation
│   │   └── theme/app_theme.dart         # Dark premium theme
│   └── features/
│       ├── auth/
│       │   ├── models/user_model.dart
│       │   ├── providers/auth_provider.dart
│       │   └── screens/
│       │       ├── splash_screen.dart
│       │       └── login_screen.dart
│       ├── dashboard/
│       │   └── screens/dashboard_screen.dart
│       ├── deliveries/
│       │   ├── models/delivery_model.dart
│       │   ├── providers/delivery_provider.dart
│       │   └── screens/
│       │       ├── deliveries_list_screen.dart
│       │       └── delivery_detail_screen.dart
│       ├── notifications/
│       │   ├── models/notification_model.dart
│       │   ├── providers/notification_provider.dart
│       │   └── screens/notifications_screen.dart
│       ├── profile/
│       │   └── screens/profile_screen.dart
│       └── history/
│           └── screens/history_screen.dart
├── android/
│   └── app/src/main/AndroidManifest.xml
├── assets/
│   ├── images/
│   ├── icons/
│   └── animations/
└── pubspec.yaml
```

---

## 🚀 Setup & Run

### Prerequisites

1. **Install Flutter SDK**: https://docs.flutter.dev/get-started/install/windows
2. **Install Android Studio** with Android SDK
3. Start your Django backend

### Steps

```bash
# 1. Navigate to mobile-app folder
cd mobile-app

# 2. Install dependencies
flutter pub get

# 3. Configure backend URL
# Edit: lib/core/constants/app_constants.dart
# → For Android Emulator:  http://10.0.2.2:8000
# → For Physical Device:   http://192.168.X.X:8000  (your PC's local IP)

# 4. Run on emulator/device
flutter run
```

### 🌐 Backend URL Configuration

Edit `lib/core/constants/app_constants.dart`:

```dart
// Android emulator → localhost
const String kBaseUrl = 'http://10.0.2.2:8000';

// Physical device on same WiFi (replace with your PC's IP)
// const String kBaseUrl = 'http://192.168.1.X:8000';
```

To find your PC's IP on Windows: `ipconfig` → look for IPv4 Address.

Make sure Django is running with:
```bash
python manage.py runserver 0.0.0.0:8000
```

---

## ✨ Features

### Phase 1 (Current)
- 🔐 **Secure Login** — JWT auth, transporter-role validation, persistent session
- 🏠 **Dashboard** — Stats (active/delivered/total), active deliveries carousel, quick actions, notifications preview
- 📦 **Deliveries List** — Active & Completed tabs, pull-to-refresh, 30s auto-polling
- 📋 **Delivery Detail** — Visual progress stepper pipeline, one-tap status advance, order/product/buyer info cards
- 🔔 **Notifications** — Real-time polling, mark read/all-read, unread badge
- 👤 **Profile** — Vehicle info, stats, approval status, logout
- 📜 **History** — Completed deliveries with earnings & kg summary

### Delivery Status Pipeline
```
ASSIGNED → ON_WAY → CHARGING → NEAR_ARRIVAL → DELIVERED
```
Each step syncs with the Django backend and triggers buyer/farmer notifications automatically.

---

## 🎨 Design System

- **Theme**: Dark premium with glassmorphism
- **Primary Color**: `#00C853` (vibrant green)
- **Accent**: `#1DE9B6` (teal)
- **Font**: Poppins (Google Fonts)
- **Animations**: Entrance fade/slide, status transitions

---

## 🔌 API Endpoints Used

| Endpoint | Purpose |
|---|---|
| `POST /api/token/` | Login (JWT) |
| `POST /api/token/refresh/` | Token refresh |
| `GET /api/users/me/` | Current user profile |
| `GET /api/market/deliveries/` | Transporter's deliveries |
| `GET/PATCH /api/market/deliveries/{id}/` | Delivery detail & status update |
| `GET /api/market/notifications/` | User notifications |
| `PATCH /api/market/notifications/{id}/` | Mark notification read |
