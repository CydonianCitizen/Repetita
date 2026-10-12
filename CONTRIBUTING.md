# Contributing to Repetita

Thank you for your interest in contributing to Repetita! Repetita is an offline-first, local-only spaced repetition flashcard application powered by the Free Spaced Repetition Scheduler (FSRS) algorithm.

Please read this guide to ensure smooth and effective contributions.

---

## 🧭 Project Non-Goals

Before proposing major architecture changes, please note our strict non-goals:
* **No Remote Backends:** No Firebase, Supabase, sync engines, or cloud accounts.
* **No Telemetry / Ads:** Zero tracking, analytics, or third-party ad networks.
* **Pure Offline Operation:** All state resides locally on-device.

---

## 🛠️ Development Setup

### 1. Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3.x+ with strict null-safety).
* Android Studio / Android SDK (API 30+) or Xcode (macOS).

### 2. Getting the Code
```bash
git clone https://github.com/CydonianCitizen/Repetita.git
cd Repetita
flutter pub get
```

### 3. Code Generation
Repetita uses Drift and Riverpod code generators. Run code generation after modifying database tables or `@riverpod` annotations:
```bash
dart run build_runner build --delete-conflicting-outputs
```
Or run the watcher during active development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 📐 Architecture & Layering Rules

Repetita follows a strict **Feature-First Layered Architecture**:

```text
lib/src/features/<feature_name>/
├── domain/       # Pure business logic, models, enums (Zero dependencies on Flutter UI, Drift, or Riverpod)
├── data/         # Drift DAOs, file I/O, persistence mapping
└── presentation/ # Widgets, screens, Riverpod Notifiers
```

* **Zero Horizontal Bloat:** Do not create pass-through repository interfaces or empty UseCases.
* **Pure Math:** The FSRS scheduling engine (`lib/src/core/algorithms/fsrs/`) must remain pure Dart with zero external package imports. Never inject `DateTime.now()` into core formulas—always pass timestamps explicitly.
* **No Raw Queries in UI:** Never execute raw SQL or Drift queries directly in Widget `build()` methods.

---

## 🧪 Testing and Quality Standards

All changes must satisfy our verification checks prior to opening a Pull Request:

1. **Static Analysis (Zero Warnings):**
   ```bash
   flutter analyze --fatal-infos --fatal-warnings
   ```
2. **Formatting:**
   ```bash
   dart format --output=none --set-exit-if-changed .
   ```
3. **Automated Tests:**
   ```bash
   flutter test --coverage
   ```
   * 100% test coverage is required for all FSRS equations and algorithmic transitions.
   * Drift DAOs must be tested with in-memory SQLite (`NativeDatabase.memory()`).

---

## 📝 Commit Conventions

All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

* `feat(feature)`: A new user-facing feature.
* `fix(feature)`: A bug fix.
* `refactor(feature)`: Code change that neither fixes a bug nor adds a feature.
* `test(feature)`: Adding or correcting tests.
* `docs`: Documentation updates.
* `ci`: Changes to CI/CD workflows and configuration.

Examples:
* `feat(study_session): implement study-ahead interval calculation`
* `fix(backup): resolve foreign key validation during merge import`
* `refactor(cards): simplify card tile status badge`

---

## 🚀 Pull Request Checklist

Before submitting your PR:
- [ ] `flutter pub get` runs cleanly without dependency conflicts.
- [ ] Code generation has been executed and generated files (`.g.dart`) are checked in.
- [ ] `flutter analyze --fatal-infos --fatal-warnings` passes with 0 issues.
- [ ] `flutter test` passes completely.
- [ ] `dart format` has been applied to all modified files.
- [ ] Conventional Commit message guidelines are followed.
