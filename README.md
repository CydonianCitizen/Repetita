# Repetita 🧠⚡

[![CI](https://github.com/CydonianCitizen/Repetita/actions/workflows/ci.yml/badge.svg)](https://github.com/CydonianCitizen/Repetita/actions/workflows/ci.yml)
![Version](https://img.shields.io/badge/version-0.5.6-blue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An offline-first, local-only spaced repetition flashcard application built with Flutter and Dart, powered by the state-of-the-art **Free Spaced Repetition Scheduler (FSRS)** algorithm.

Repetita is crafted for privacy, mathematical precision, and high performance. It operates completely disconnected from remote servers and cloud backends—your study data, retention history, and decks remain 100% on your device.

---

## 🌟 Key Features

* **Deterministic FSRS Scheduling:**
  * Implements pure domain FSRS (Free Spaced Repetition Scheduler v4/v5) calculating stability ($S$), difficulty ($D$), and retrievability ($R$) with mathematical determinism.
  * Preview interval calculations on rating buttons (`Again`, `Hard`, `Good`, `Easy`) before confirming.
* **100% Offline-First & Private:**
  * Zero analytics, telemetry, cloud databases (no Firebase, no Supabase), or user accounts.
  * Complete data sovereignty with zero latency and full offline functionality.
* **Reactive Local Persistence (Drift / SQLite):**
  * Type-safe local database powered by Drift with reactive streams (`watch()`) for instantaneous UI updates.
  * Relational integrity with cascading foreign keys (`Decks` ➔ `Cards` ➔ `ReviewLogs`).
* **Study & Active Recall Session:**
  * Smooth card flip animations separating prompt and answer recall.
  * Session progress indicator, queue counter, and atomic review logging.
* **Retention Metrics & 7-Day Forecast:**
  * Real-time retention accuracy percentage and total reviews counter.
  * Card maturity distribution (New, Learning, Review, Relearning).
  * 7-day workload forecast chart.
* **Data Ownership (Import & Export):**
  * Full database backup and restore via standard JSON payloads.
  * CSV export and import support for quick card sharing and desktop migration.
* **Material 3 Design & Accessibility:**
  * Adaptive Material 3 light and dark themes.
  * Semantic screen-reader annotations on cards and action triggers.
  * Minimum 48×48 dp accessible touch targets.

---

## 🏗️ Architecture & Technology Stack

Repetita follows a strict **Feature-First Layered Architecture**:

```text
lib/
├── main.dart
└── src/
    ├── app.dart                          # Root MaterialApp, AppTheme & routing
    ├── core/                             # Cross-cutting foundational modules
    │   ├── algorithms/
    │   │   └── fsrs/                     # Pure Dart FSRS model, formulas, and math engine
    │   ├── database/                     # Drift central database definition & connection
    │   └── theme/                        # Material 3 light/dark themes
    └── features/
        ├── decks/                        # Deck management (CRUD, deck tiles, creation modal)
        ├── cards/                        # Card management & dual-pane content editor
        ├── study_session/                # Review loop, flip card, active recall UI
        ├── stats/                        # Aggregated analytics, retention rate & forecast
        └── backup_transfer/              # JSON/CSV local backup, import & export services
```

### Core Technologies

| Component | Choice | Purpose |
| :--- | :--- | :--- |
| **Framework** | **Flutter & Dart 3.x** | Cross-platform UI with strict null-safety |
| **State Management** | **Riverpod 2.x** | Reactive dependency injection & code generation (`@riverpod`) |
| **Persistence** | **Drift (SQLite)** | High-performance, reactive local SQL with migrations |
| **Spaced Repetition** | **FSRS Algorithm** | Zero-dependency pure Dart scheduling engine |
| **Design System** | **Material 3** | Adaptive dynamic theming and accessible contrast |
| **Serialization** | **Freezed & json_serializable** | Immutable domain models and safe serialization |

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3.x+)
* Android Studio / Android SDK (for Android builds or emulator)
* Xcode (for iOS builds, macOS only)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/Repetita.git
   cd Repetita
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (Drift & Riverpod):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run on connected device or emulator:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Verification

Repetita maintains a comprehensive test suite including 100% unit test coverage for the FSRS math engine, Drift DAO database tests, widget tests, and full end-to-end user journeys:

```bash
# Run all tests (unit, widget, integration)
flutter test

# Format validation
dart format --output=none --set-exit-if-changed .

# Static analysis (zero warnings allowed)
flutter analyze --fatal-infos --fatal-warnings

# Build debug APK locally
flutter build apk --debug
```

---

## 🤖 F-Droid Readiness & Open Source Compliance

Repetita is fully compatible with F-Droid and free/open-source distribution standards:

* **Zero Proprietary Blobs:** Contains no Google Mobile Services (GMS), Firebase, crash reporting libraries, proprietary advertising, or tracking SDKs.
* **Local Notifications:** Daily reminders are implemented using Android's native `AlarmManager` and `NotificationManager` via `flutter_local_notifications`. No push notification services or external daemons are used.
* **Core Library Desugaring:** The Android build configuration (`android/app/build.gradle.kts`) enables Java 8+ API desugaring (`isCoreLibraryDesugaringEnabled = true`) using the open-source `com.android.tools:desugar_jdk_libs:2.1.4`.
* **Reproducible Local Build:**
  ```bash
  flutter build apk --release --split-per-abi
  ```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
