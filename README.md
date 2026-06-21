# Golden Notes 🪶

A dark-themed, gold-accented notes app for Android with folders and a
view/edit toggle. Built with Flutter.

## Features
- **Dark UI with gold accents** throughout
- **Folders** — create, open, delete (deleting a folder deletes its notes too)
- **Notes open in read-only "view mode" by default.** Tap the pencil
  icon in the top-right to unlock editing. Tap the checkmark to save
  and return to view mode.
- **Local persistent storage** via Hive — notes are saved to the
  device and survive app restarts (no internet/account needed)
- Empty notes are auto-discarded so you don't end up with junk entries

## How to build the APK yourself

You'll need:
1. **Flutter SDK** installed — https://docs.flutter.dev/get-started/install
2. **Android Studio** (or just the Android SDK command-line tools) installed
3. A device or emulator to test on (optional but recommended)

### Steps

```bash
# 1. Unzip/copy this project folder, then open a terminal inside it
cd golden_notes

# 2. Get the Flutter packages
flutter pub get

# 3. Confirm everything is set up correctly
flutter doctor

# 4. Build the release APK
flutter build apk --release
```

Your APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Copy that file to your phone and install it (you may need to enable
"Install from unknown sources" in Android settings).

### If you'd rather use Android Studio (easiest for beginners)
1. Open Android Studio → "Open" → select the `golden_notes` folder
2. Let it sync (it will auto-generate `android/local.properties` for you)
3. Click the green ▶ Run button to install on a connected device/emulator,
   OR go to **Build → Build Bundle(s)/APK(s) → Build APK(s)** to just get
   the APK file

### Notes on the project setup
- `minSdkVersion` is set to 21 (Android 5.0+), which covers virtually all
  active Android devices.
- The app currently builds the release APK with **debug signing** so it
  builds out of the box with zero extra setup. This is fine for personal
  use/testing. If you ever publish to the Play Store, you'll need to
  generate your own signing key and update `android/app/build.gradle`
  accordingly (Flutter's docs have a short guide on this: "Sign the app").
- Hive's generated adapter files (`*.g.dart` in `lib/models/`) are
  included pre-written, so you do **not** need to run `build_runner` —
  the project compiles immediately with just `flutter pub get`.
- A simple gold notebook-icon launcher icon is included at all standard
  densities (`android/app/src/main/res/mipmap-*/ic_launcher.png`). Feel
  free to swap these out with your own design — keep the same filenames
  and sizes (48/72/96/144/192 px).

## Project structure
```
lib/
  main.dart                  → app entry point, sets up Hive + theme
  theme/app_theme.dart       → dark + gold color palette & ThemeData
  models/
    note.dart / note.g.dart       → Note data model + Hive adapter
    folder.dart / folder.g.dart   → Folder data model + Hive adapter
  services/notes_database.dart    → Hive box read/write/delete logic
  screens/
    folders_screen.dart      → home screen, list of folders
    notes_list_screen.dart   → notes inside a selected folder
    note_view_screen.dart    → view/edit screen with the pencil toggle
```

## Customizing the look
All colors live in `lib/theme/app_theme.dart` under `AppColors`. The
main gold accent is `#D4AF37` — change that one constant to shift the
whole app's accent color.
