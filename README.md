# Repetita 🧠⚡

[![CI](https://github.com/CydonianCitizen/Repetita/actions/workflows/ci.yml/badge.svg)](https://github.com/CydonianCitizen/Repetita/actions/workflows/ci.yml)
![Version](https://img.shields.io/badge/version-0.7.5-blue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An offline-first, local-only spaced repetition flashcard application built with Flutter and Dart, powered by the state-of-the-art **Free Spaced Repetition Scheduler (FSRS)** algorithm with an extensible multi-engine architecture.

Repetita is crafted for privacy, mathematical precision, and high performance. It operates completely disconnected from remote servers and cloud backends—your study data, retention history, and decks remain 100% on your device.

---

## 🌟 Key Features

* **Deterministic SRS Scheduling (FSRS Engine & Multi-Algorithm Abstraction):**
  * Pluggable `SrsScheduler` strategy architecture isolating domain mathematics from UI controllers.
  * Zero-dependency implementation of FSRS (Free Spaced Repetition Scheduler v4/v5) calculating stability ($S$), difficulty ($D$), and retrievability ($R$) with pure mathematical determinism.
  * Preview interval calculations on rating buttons (`Again`, `Hard`, `Good`, `Easy`) before confirming.
  * Architecture prepared for upcoming SM-2 (SuperMemo) algorithm integration.
* **Desktop Edition (Windows x64 & macOS Universal):**
  * Native desktop performance on Windows (Win32 runner with MSVC ATL shim) and macOS (Universal 2 binary for both Apple Silicon and Intel).
  * Ergonomic keyboard shortcuts: `Space`/`Enter` to flip card, `1`–`4` for rating submission, `Ctrl+Z`/`Cmd+Z` for 1-step undo, `Ctrl+Enter`/`Cmd+Enter` to save cards.
  * Responsive Material 3 layout: auto-adapting between `NavigationRail` (>= 640px) and bottom `NavigationBar`.
* **Flexible Study Modes & Card Types:**
  * Cloze deletions (`{{c1::answer}}` and `{{c1::answer::hint}}`) with atomic card batching.
  * Custom Study (Cram Mode / Free Review) for exam prep and non-destructive reviews.
  * 1-step Undo Review, card suspension (Suspend), and daily postponement (Bury).
* **Comprehensive Ecosystem & Data Ownership:**
  * Native Anki package (`.apkg`) import with media extraction, HTML-to-markdown sanitation, and model mapping.
  * Native file picker and system saver integration for `.apkg`, `.json`, and `.csv`.
  * Full database backup and restore via standard JSON payloads.
  * CSV export and import support for quick card sharing and tabular migration.
* **100% Offline-First & Private:**
  * Zero analytics, telemetry, crash reporting SDKs, cloud databases (no Firebase, no Supabase), or user accounts.
  * Complete data sovereignty with zero latency and full offline functionality.
  * Onboarding deck seeder (`SampleDeckSeeder`) providing beginner cards on first run without external network assets.
* **Retention Metrics & Visual Analytics:**
  * 15-week activity heatmap and study streak tracking.
  * Real-time retention accuracy percentage and maturity distribution (New, Learning, Review, Relearning).
  * 7-day workload forecast chart.
* **Material 3 Design & Accessibility:**
  * Adaptive Material 3 light and dark themes.
  * Semantic screen-reader annotations and accessible touch targets (>= 48×48 dp).

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
    │   │   ├── srs/                      # Pure Dart SrsScheduler interface & contracts
    │   │   ├── fsrs/                     # Pure Dart FSRS model, formulas, and math engine
    │   │   └── cloze/                    # Pure Dart cloze deletion text parser
    │   ├── database/                     # Drift central database definition & connection
    │   └── theme/                        # Material 3 light/dark themes
    └── features/
        ├── decks/                        # Deck management (CRUD, deck tiles, sample seeder)
        ├── cards/                        # Card management, search & dual-pane content editor
        ├── study_session/                # Review loop, flip card, active recall UI & scheduler provider
        ├── stats/                        # Aggregated analytics, retention rate & forecast
        ├── settings/                     # App settings, reminders, and algorithm selection
        └── backup_transfer/              # Anki (.apkg), JSON/CSV local backup & export services
```

### Core Technologies

| Component | Choice | Purpose |
| :--- | :--- | :--- |
| **Framework** | **Flutter & Dart 3.x** | Multi-platform UI (Android, iOS, Windows, macOS) |
| **State Management** | **Riverpod 2.x** | Reactive dependency injection & code generation (`@riverpod`) |
| **Persistence** | **Drift (SQLite)** | High-performance, reactive local SQL with migrations |
| **Spaced Repetition** | **SrsScheduler Strategy** | Extensible pure Dart scheduling engine (FSRS v4/v5 + upcoming SM-2) |
| **Design System** | **Material 3** | Adaptive dynamic theming, NavigationRail (desktop) & accessible contrast |
| **Serialization** | **Immutable Value Classes** | Hand-written `final`-field classes with manual `toJson`/`fromJson` |

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3.x+)
* **Android:** Android Studio / Android SDK (API 30+)
* **Windows:** Visual Studio 2022 with C++ desktop workload
* **macOS:** Xcode 15+ (macOS 12.0+ deployment target)
* **iOS:** Xcode (simulator / sideloading)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/CydonianCitizen/Repetita.git
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

4. **Run on connected device or desktop:**
   ```bash
   # Run on default connected device / emulator
   flutter run

   # Run on desktop target
   flutter run -d windows
   flutter run -d macos
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

# Build local target binaries
flutter build apk --release --split-per-abi  # Android split APKs
flutter build windows --release              # Windows x64 executable
flutter build macos --release                # macOS Universal 2 app
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
