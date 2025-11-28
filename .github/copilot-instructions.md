Purpose
-------
This file helps an AI coding agent get productive quickly in this Flutter codebase. It documents the app's architecture, the main data flows, developer workflows (build/test/debug), and a few project-specific patterns to follow when making changes.

Big picture
-----------
- Flutter application with a layered feature structure under `lib/src/features/<feature>`.
- Each feature follows a lightweight Clean-Architecture layout: `data/`, `domain/`, `presentation/`.
- App entry: `lib/main.dart` -> `lib/src/bootstrap.dart` -> `lib/src/app.dart`.
- Router: `lib/src/core/router/app_router.dart` (maps routes; `/` -> `LoginPage`).

Typical data flow (concrete example: Login)
------------------------------------------------
LoginPage (`lib/src/features/auth/presentation/pages/login_page.dart`)
  -> constructs `AuthController` (`presentation/controllers/auth_controller.dart`)
  -> `LoginUseCase` (`domain/usecases/login.dart`)
  -> `AuthRepositoryImpl` (`data/repositories/auth_repository_impl.dart`)
  -> `AuthRemoteDataSource` (`data/datasources/auth_remote_data_source.dart`)
  -> returns `UserDto` (`data/models/user_dto.dart`) mapped to domain `User` (`domain/entities/user.dart`).

Key files & directories
-----------------------
- `lib/src/bootstrap.dart` — bootstrapping and `initDependencies()` hook (DI entrypoint).
- `lib/src/core/di/di.dart` — dependency registration point; `bootstrap()` calls `initDependencies()`.
- `lib/src/core/router/app_router.dart` — route definitions.
- `lib/src/core/theme/` — app theming tokens and `AppTheme`.
- `lib/src/core/shared/` — small shared widgets (e.g., `PrimaryButton`).

Project-specific patterns & gotchas
---------------------------------
- Layering: keep code inside the feature folder for related behavior (data/domain/presentation).
- Current DI: `initDependencies()` is present but empty. Many pages (e.g., `LoginPage.initState`) manually instantiate repository/usecase/controller. When modifying dependency wiring, keep both styles consistent and update `initDependencies()` if you centralize DI.
- Controllers: presentation controllers are `ChangeNotifier` (e.g., `AuthController`). Note: `LoginPage` currently constructs the controller but does not attach a listener. If you change controller internals to call `notifyListeners()`, make sure the UI subscribes (for example via `controller.addListener(() => setState(() {}));`, `AnimatedBuilder`, or integrate Provider/Riverpod consistently).
- Remote/data source: `AuthRemoteDataSource` is a local stub (returns fake data after a delay). Replace with an HTTP client only where tests and other code expect network behavior.
- Mappers: DTO -> Domain mapping lives under `data/mappers` (see `UserMapper`). Use these when converting external data into domain entities.

Build / run / test workflows
---------------------------
- Install deps: `flutter pub get`
- Run (desktop): `flutter run -d windows`
- Run (Android emulator/device): `flutter run -d android`
- Build APK: `flutter build apk`
- Run tests: `flutter test`
- Static analysis: `dart analyze` or `flutter analyze`
- Format: `dart format .`
Note: this repository includes platform folders for Android, iOS, macOS, Linux, Windows and web — use the appropriate `-d <device>` flag or CI config for platform-specific builds.

When editing code
-----------------
- Small changes: follow existing file layout and naming. Add new features under `lib/src/features/<feature>` with `data/domain/presentation` structure.
- If you introduce DI registration, put it in `lib/src/core/di/di.dart` and ensure `bootstrap()` calls remain correct.
- If you change controllers to emit events (`notifyListeners()`), update consumer widgets to listen.

Where to look for examples
--------------------------
- Login flow: `lib/src/features/auth/...` (complete example of layers and mapping).
- Router: `lib/src/core/router/app_router.dart`.
- Theme and shared widgets: `lib/src/core/theme/`, `lib/src/core/shared/`.

If something is unclear or you need deeper rules (naming conventions, preferred DI library, preferred state management), ask the maintainer before making cross-cutting changes.

---
Please review and tell me any missing specifics (CI, code style rules, preferred DI/state library) to add or any existing guidance to preserve.
