# Crimson Map v2

**An Augmented Reality Campus Navigation System for Western Mindanao State University (WMSU)**

> Crimson Map v2 is a complete rebuild of the original Unity-based AR navigation app. The first version was built entirely in Unity 2022 (C#) with native AR markers, QR scanning, Supabase integration, and Mapbox-powered maps — all within a single Unity project. While functional, iterating on the UI was slow and cumbersome inside the Unity editor. v2 migrates the frontend, styling, and application shell to Flutter, while the proven Unity AR core is retained and bridged via a Flutter–Unity method channel.

---

## What's New in v2

| | v1 (Unity) | v2 (Flutter + Unity Bridge) |
|---|---|---|
| **Frontend** | Unity UI Toolkit / uGUI | Flutter (Material 3) |
| **AR Engine** | Unity AR Foundation (C#) | Unity AR Foundation (C#) — unchanged |
| **State Management** | Unity MonoBehaviours | Riverpod |
| **Navigation** | Unity SceneManager | GoRouter |
| **Database** | Supabase (C# SDK) | Supabase Flutter SDK |
| **Maps** | Mapbox Unity SDK | Mapbox Maps Flutter |
| **QR Scanning** | ZXing (Unity) | mobile_scanner |
| **Architecture** | Monolithic Unity project | Feature-first Clean Architecture |

---

## Features

- **AR Navigation** — Point-and-go augmented reality directions powered by the Unity AR module (AR Foundation, C#)
- **QR Code Scanning** — Scan markers placed around campus to instantly trigger navigation to that destination
- **Interactive Campus Map** — Mapbox-powered map centered on the WMSU campus
- **Destination Explorer** — Browse and search all buildings, offices, and rooms by category
- **Onboarding Flow** — Guided first-launch walkthrough
- **Authentication** — Supabase-backed sign-in for WMSU accounts
- **Dark Mode** — Full light/dark theme support

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3 (Dart) |
| AR Module | Unity 2022 (C#) via `flutter_unity_widget` |
| State Management | Riverpod |
| Routing | GoRouter |
| Backend / Auth | Supabase |
| Maps | Mapbox Maps Flutter |
| QR Scanning | mobile_scanner |
| Location | geolocator |
| Permissions | permission_handler |

---

## Architecture

Crimson Map v2 follows **Feature-First Clean Architecture**. Each feature is self-contained with its own `data`, `domain`, and `presentation` layers. The Unity AR module is treated as an external integration accessed through a dedicated service.

```
lib/
├── core/
│   ├── constants/       # App-wide constants, strings, asset paths
│   ├── theme/           # Colors, text styles, MaterialApp theme
│   ├── utils/           # Validators, helpers, distance & permission utils
│   ├── services/        # Supabase, Location, Mapbox, Unity bridge
│   └── errors/          # Exception and Failure classes
│
├── shared/
│   ├── widgets/         # Reusable UI components (AppBar, Button, Loader…)
│   └── extensions/      # BuildContext and String extensions
│
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── navigation_shell/
│   ├── auth/            # Login, user entity, Supabase auth datasource
│   ├── home/
│   ├── explore/         # Destination & building search/browse
│   ├── qr_scanner/      # Camera QR scan → destination resolution
│   ├── ar_navigation/   # Route fetching, Unity payload building, AR screen
│   └── settings/
│
├── routes/              # GoRouter configuration and route name constants
└── main.dart
```

Each feature with backend interactions follows the standard three-layer pattern:

```
feature/
├── data/
│   ├── datasources/     # Supabase / remote calls
│   ├── models/          # JSON-serializable model classes (extend entities)
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Pure Dart business objects
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # Single-responsibility use case classes
└── presentation/
    ├── screens/         # Full-screen widgets
    ├── widgets/         # Feature-scoped UI components
    └── providers/       # Riverpod Notifiers
```

---

## Flutter–Unity Bridge

The AR navigation is handled entirely by the Unity module. Flutter communicates with it through a `MethodChannel` (`com.crimsonmap.unity_bridge`) via `flutter_unity_widget`.

**Flow:**
1. User selects a destination (from Explore or QR scan)
2. `ArProvider` fetches the route from Supabase
3. `ArPayloadBuilder` converts the route into a JSON map
4. `UnityBridgeService.startNavigation(payload)` sends it to Unity
5. Unity renders AR arrows and markers over the camera feed

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.4`
- Dart SDK `^3.10.4`
- Unity 2022 (for modifying the AR module)
- A Supabase project with the WMSU campus data
- A Mapbox account and access token

### Environment Setup

This project uses compile-time environment variables. Pass them via `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token
```

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/crimson_map.git
cd crimson_map

# Install dependencies
flutter pub get

# Run on a connected device
flutter run
```

### Unity Module

The Unity AR project is located in the `unity/` directory. To rebuild the Unity library:

1. Open the project in Unity 2022
2. Go to **File → Build Settings → Android / iOS**
3. Click **Export** to the `android/unityLibrary` or `ios/UnityLibrary` directory
4. Run `flutter pub get` and rebuild the Flutter app

---

## Project Information

| | |
|---|---|
| **University** | Western Mindanao State University (WMSU) |
| **Campus** | Main Campus, Baliwasan, Zamboanga City |
| **Version** | 2.0.0 |
| **Platform** | Android, iOS |
| **License** | All rights reserved |
