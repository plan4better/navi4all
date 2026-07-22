# Navi4All - Kaiserslautern

![Navi4All](/apps/kl_mobile/assets/kl_mobile_screenshots.png)

## Features
- User profiles for multiple accessibility modes (blind, vision impaired, general)
- Place search including POIs, addresses and streets
- Favourites with drag-and-drop sorting
- Multi-modal itinerary planning with customisable mode, speed and accessibility options
- Step-by-step navigation instructions with audio-cues and haptic feedback

## App Architecture

![kl_mobile architecture diagram](/apps/kl_mobile/assets/kl_mobile_architecture_diagram.svg)

* View Layer: UI-related components (screens, widgets)
* Controller Layer: State management, interface between View and Service layers
* Service Layer: API clients, response parsing
* DTOs: Data Transfer Objects for API communication

## Deployment

### System Requirements

- Flutter SDK with Dart 3.8+ (`flutter --version`)
- VS Code / Android Studio + Android SDK (for Android builds/runs)
- Xcode 15+ (for iOS builds/runs on macOS)
- A connected device or emulator/simulator

### Environment Configuration

1. Install and setup Flutter

   Follow the [official installation guide](https://docs.flutter.dev/install/quick) from Flutter to get started on your local system and IDE of choice.

2. Create your local `.env` configuration

   Sensitive/configurable values are provided via compile-time Dart defines.

   ```bash
   cp .env.example .env
   ```

3. Adjust values in `.env` (this file is gitignored).

Note:

`.env.example` is configured for local core backend usage (`http://localhost:8010/v1/`).

### Run from CLI

```bash
flutter run --dart-define-from-file=.env
```

### Build from CLI

```bash
flutter build apk --release --dart-define-from-file=.env
```

### Run from VS Code

Use the workspace launch configuration `kl_mobile`, which already includes:

`--dart-define-from-file=.env`

Note: Changing `.env` values requires stopping and rerunning the app (hot reload does not refresh compile-time defines).

## Translation Guide
This app currently supports the following locales:
- `en` - English
- `de` - German

App-wide strings are located in the `kl_mobile/lib/i10n/app_[locale].arb` files, where `[locale]` is the language code (e.g. `de`).

All strings must have a 1:1 mapping accross locales, meaning that if a string is present in one locale, it must also be present in all other locales.

The following steps should be performed while translating:
* Open the `app_[locale].arb` file for the locale you want to translate
* Translate the value of each key, ensuring that the key itself remains unchanged
* Confirm existing parameter positioning is retained in translated strings
* Preserve newline characters (`\n`) in strings, as they may affect the layout of the app
* Try to retain similar lengths for translated strings, as this can help maintain the app's layout
* Save the `app_[locale].arb` file once translation is complete
* From the root directory of the project, run the following command:
   ```bash
   flutter gen-l10n
   ```
   Note: This command requires the Flutter SDK to be installed.