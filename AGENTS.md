# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

Sement Market is a Flutter mobile app (Android/iOS) for a cement/building materials marketplace, targeting users in Uzbekistan. It uses Clean Architecture with BLoC pattern, Dio for HTTP, GoRouter for navigation, and Firebase for push notifications.

### Environment requirements

- **Flutter SDK**: 3.41.x (requires Dart >=3.9 for `go_router ^17.1.0` and Dart >=3.8 for `flutter_lints ^6.0.0`). The SDK is installed at `~/flutter`.
- **Android SDK**: Installed at `~/android-sdk`. Licenses are pre-accepted.
- **Java**: OpenJDK 21 (system-provided, matches `build.gradle.kts` config).

### Common commands

| Task | Command |
|---|---|
| Install deps | `flutter pub get` |
| Lint / analyze | `flutter analyze` |
| Run tests | `flutter test` |
| Build debug APK | `flutter build apk --debug` |
| Build release AAB | `flutter build appbundle` |

### Known issues

- `test/widget_test.dart` references `MyApp` but the app class is `SementMarketCustomerApp`. This causes `flutter test` and `flutter analyze` to report 1 error. This is a pre-existing scaffold issue in the repo.
- The backend API URL (`http://10.143.192.70:8000/api/v1`) is hardcoded in `lib/core/api/api_client.dart`. The backend is on a private network and not accessible from the cloud VM. The app still builds/runs but API calls will fail without a reachable backend.
- Firebase config files (`google-services.json`, `GoogleService-Info.plist`) are missing from the repo. Firebase init is wrapped in try/catch so the app won't crash, but push notifications won't work.
- The project is mobile-only (Android/iOS). To demo in browser, temporarily add web support with `flutter create . --platforms web`, build with `flutter build web --no-tree-shake-icons`, then serve `build/web/` with any HTTP server. Clean up with `git checkout -- . && git clean -fd web/ .idea/`.

### PATH setup

The following must be on `PATH` for Flutter and Android SDK to work:

```
export PATH="$HOME/flutter/bin:$HOME/flutter/bin/cache/dart-sdk/bin:$HOME/android-sdk/cmdline-tools/latest/bin:$HOME/android-sdk/platform-tools:$PATH"
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$HOME/android-sdk"
```

These are already added to `~/.bashrc`.
