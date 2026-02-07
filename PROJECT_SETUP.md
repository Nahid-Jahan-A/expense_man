# Expense Manager - Project Setup & Configuration Guide

## Required SDK Versions

| Tool          | Version       | Notes                        |
|---------------|---------------|------------------------------|
| Flutter       | **3.38.9**    | Stable channel               |
| Dart          | **3.10.8**    | Bundled with Flutter          |
| DevTools      | **2.51.1**    | Bundled with Flutter          |

### Install Flutter

```bash
# macOS (Homebrew)
brew install --cask flutter

# Or download directly from https://docs.flutter.dev/get-started/install/macos

# Windows: Download from https://docs.flutter.dev/get-started/install/windows

# Verify installation
flutter --version
# Expected: Flutter 3.38.9 | Dart 3.10.8
```

If you have a different Flutter version, switch to the correct one:

```bash
flutter channel stable
flutter upgrade
# Or pin to exact version using fvm (Flutter Version Management):
# dart pub global activate fvm
# fvm install 3.38.9
# fvm use 3.38.9
```

---

## Java / JDK

| Tool | Version     |
|------|-------------|
| JDK  | **17**      |

Java 17 is required for Android Gradle Plugin 8.7.0. Install via:

```bash
# macOS
brew install openjdk@17

# Set JAVA_HOME (add to ~/.zshrc or ~/.bash_profile)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

---

## Android Configuration

| Setting                  | Value            |
|--------------------------|------------------|
| Android Gradle Plugin    | **8.7.0**        |
| Gradle                   | **8.10.2**       |
| Kotlin                   | **1.8.22** (upgrade to **2.1.0+** recommended) |
| NDK Version              | **27.0.12077973**|
| `compileSdk`             | Managed by Flutter |
| `minSdk`                 | **23** (Android 6.0) |
| `targetSdk`              | Managed by Flutter |
| Java Compatibility       | **11** (source & target) |

> **Note:** Flutter 3.38+ recommends Kotlin 2.1.0 or higher. You may see a warning during builds until Kotlin is upgraded.

### Gradle JVM Args (android/gradle.properties)

```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
```

### Google Services Plugin

```
com.google.gms.google-services version 4.4.2
```

---

## iOS Configuration

| Setting                         | Value     |
|---------------------------------|-----------|
| Minimum iOS Deployment Target   | **12.0**  |

### Important: No Podfile exists yet

The `ios/Podfile` is not checked in. After cloning, you must generate it:

```bash
cd ios
pod init
# Or simply run:
flutter build ios
# Flutter will generate the Podfile automatically
```

### CocoaPods

CocoaPods is required for iOS builds (Firebase and other native plugins).

```bash
# Install CocoaPods
sudo gem install cocoapods
# Or via Homebrew:
brew install cocoapods

# Install pods after Podfile is generated
cd ios && pod install
```

---

## macOS Configuration

| Setting                          | Value     |
|----------------------------------|-----------|
| Minimum macOS Deployment Target  | **10.14** |

### Entitlements

The macOS runner has the following entitlements configured:

- **DebugProfile**: App Sandbox, JIT, Network Server
- **Release**: App Sandbox only

---

## Firebase Setup

This project uses Firebase for **Auth**, **Storage**, and **Core**. Firebase is currently configured **only for Android**.

### Platforms NOT configured for Firebase:

- iOS
- macOS
- Windows
- Linux
- Web

### To configure Firebase for iOS/macOS on your Mac:

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run FlutterFire configure (from project root):
   ```bash
   flutterfire configure
   ```
   This will:
   - Create `GoogleService-Info.plist` for iOS
   - Update `lib/firebase_options.dart` with iOS/macOS options
   - Register your app with the Firebase project (`expense-manager-fd54a`)

3. For iOS, after configuring, run:
   ```bash
   cd ios && pod install
   ```

### Firebase Project Info

| Key                | Value                                  |
|--------------------|----------------------------------------|
| Project ID         | `expense-manager-fd54a`                |
| Storage Bucket     | `expense-manager-fd54a.firebasestorage.app` |

---

## Dependencies (pubspec.yaml)

### Direct Dependencies

| Package                  | Version        | Category          |
|--------------------------|----------------|-------------------|
| flutter_bloc             | ^8.1.6         | State Management  |
| hydrated_bloc            | ^9.1.5         | State Management  |
| equatable                | ^2.0.5         | State Management  |
| hive                     | ^2.2.3         | Local Storage     |
| hive_flutter             | ^1.1.0         | Local Storage     |
| path_provider            | ^2.1.4         | Local Storage     |
| pdf                      | ^3.11.1        | PDF Export        |
| printing                 | ^5.13.3        | PDF Export        |
| open_filex               | ^4.5.0         | PDF Export        |
| fl_chart                 | ^0.69.0        | Charts            |
| flutter_animate          | ^4.5.0         | UI/UX             |
| lottie                   | ^3.1.2         | UI/UX             |
| google_fonts             | ^6.2.1         | UI/UX             |
| flutter_svg              | ^2.0.10+1      | UI/UX             |
| shimmer                  | ^3.0.0         | UI/UX             |
| intl                     | ^0.20.2        | Localization      |
| uuid                     | ^4.5.1         | Utils             |
| get_it                   | ^8.0.2         | Utils             |
| dartz                    | ^0.10.1        | Utils             |
| rxdart                   | ^0.28.0        | Utils             |
| share_plus               | ^10.1.4        | Utils             |
| file_picker              | ^8.1.6         | Utils             |
| go_router                | ^14.6.2        | Navigation        |
| flex_color_picker         | ^3.6.0         | Color Picker      |
| permission_handler       | ^11.3.1        | Permissions       |
| firebase_core            | ^3.8.1         | Firebase          |
| firebase_storage         | ^12.3.7        | Firebase          |
| firebase_auth            | ^5.3.4         | Firebase          |
| google_sign_in           | ^6.2.2         | Firebase          |
| cupertino_icons          | ^1.0.8         | Icons             |
| flutter_native_splash    | ^2.4.4         | Splash Screen     |

### Dev Dependencies

| Package           | Version    |
|-------------------|------------|
| flutter_lints     | ^5.0.0     |
| build_runner      | ^2.4.13    |
| hive_generator    | ^2.0.1     |
| bloc_test         | ^9.1.7     |
| mocktail          | ^1.0.4     |

---

## Localization

The project uses Flutter's built-in localization with `flutter_localizations` and `intl`.

- `generate: true` is set in `pubspec.yaml` under the `flutter:` section
- Localization ARB files are in `assets/lang/`

---

## Assets

The following asset directories must exist:

```
assets/
  lang/       # Localization ARB files
  lottie/     # Lottie animation JSON files
  icons/      # SVG/PNG icon assets
  fonts/      # Custom font files
```

---

## Full Setup Steps (Mac - Fresh Clone)

```bash
# 1. Clone the repository
git clone <repo-url>
cd expense_manager

# 2. Ensure correct Flutter version
flutter --version
# Must be: Flutter 3.38.9 / Dart 3.10.8
# If not, see "Install Flutter" section above

# 3. Ensure JDK 17 is installed and active
java -version
# Must be: 17.x

# 4. Get dependencies
flutter pub get

# 5. Run code generation (Hive adapters)
dart run build_runner build --delete-conflicting-outputs

# 6. Generate native splash screen assets
dart run flutter_native_splash:create

# 7. Configure Firebase for iOS/macOS (REQUIRED if running on iOS/macOS)
dart pub global activate flutterfire_cli
flutterfire configure
# Select the existing project: expense-manager-fd54a
# Enable iOS and/or macOS platforms

# 8. For iOS: install CocoaPods dependencies
cd ios && pod install && cd ..

# 9. Verify setup
flutter doctor -v

# 10. Run the app
flutter run
```

---

## Troubleshooting

### "DefaultFirebaseOptions have not been configured for ios/macos"

Firebase is only configured for Android in this project. Run `flutterfire configure` to add iOS/macOS support. See the **Firebase Setup** section above.

### CocoaPods errors on macOS

```bash
sudo gem install cocoapods
# or
brew install cocoapods

cd ios && pod install --repo-update
```

### Gradle build failures

- Ensure JDK 17 is installed (`java -version`)
- Ensure `JAVA_HOME` points to JDK 17
- Run `cd android && ./gradlew clean` then retry

### "MinimumOSVersion" or deployment target errors

- iOS minimum: **12.0**
- macOS minimum: **10.14**
- Android minSdk: **23**

### Xcode version

Xcode 15+ is recommended for Flutter 3.38.x on macOS. Ensure command-line tools are installed:

```bash
xcode-select --install
sudo xcodebuild -license accept
```

### flutter pub get fails

Delete lockfile and regenerate:

```bash
rm pubspec.lock
flutter pub get
```

---

## IDE Setup

### VS Code

Recommended extensions:
- Flutter
- Dart
- Bloc (for BLoC pattern support)

### Android Studio

- Install Flutter and Dart plugins
- Set SDK path in Preferences > Languages & Frameworks > Flutter
