# AgriShield App Icon Configuration

## Icon Setup Instructions

### Step 1: Save the App Icon
1. Save the provided app icon (green leaf with medical cross) as `app_icon.png` 
2. Place it in the following location:
   ```
   mobile_app/assets/images/app_icon.png
   ```

**Note**: The icon should be at least 1024x1024 pixels for best results.

---

## Step 2: Generate App Icons for All Platforms

Once you've placed the `app_icon.png` in the correct location, run the following command to automatically generate all required icon sizes:

```bash
cd mobile_app
flutter pub get
flutter pub run flutter_launcher_icons
```

This command will automatically create:

### Android Icons
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (various DPI versions)
- Updates `AndroidManifest.xml` automatically

### iOS Icons
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (all required sizes)
- Configuration handled by flutter_launcher_icons

### Web Icons (Optional)
- Web icon in `web/icons/` folder

---

## App Name Change Summary

The following changes have been made:

### ✅ Completed Changes

1. **pubspec.yaml**
   - App name: `anaj_ai_mobile` → `agrisheild`
   - Added `flutter_launcher_icons` to dev dependencies
   - Added icon configuration pointing to `assets/images/app_icon.png`

2. **Android Configuration**
   - `android/app/src/main/AndroidManifest.xml`
   - App label: `anaj_ai_mobile` → `AgriShield`

3. **iOS Configuration**
   - `ios/Runner/Info.plist`
   - CFBundleDisplayName: `Anaj Ai Mobile` → `AgriShield`
   - CFBundleName: `anaj_ai_mobile` → `agrisheild`

4. **Flutter App**
   - `lib/main.dart`
   - App title: `Anaj.ai` → `AgriShield`

---

## Icon Specifications

- **Platform**: Android & iOS
- **Primary Color**: Green (#009B77) - already matches your theme
- **Medical Symbol**: White plus sign on green leaf background
- **Format**: PNG with transparency
- **Minimum Size**: 1024x1024 pixels (recommended)

---

## Troubleshooting

### If icons don't generate:
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
```

### If icons still don't appear:
1. Rebuild the app:
   ```bash
   flutter run
   ```

2. For iOS, you might need to rebuild the iOS build folder:
   ```bash
   flutter clean
   cd ios
   rm -rf Pods
   rm Podfile.lock
   cd ..
   flutter pub get
   flutter run
   ```

---

## Final Steps

1. **Save the icon** to `mobile_app/assets/images/app_icon.png`
2. **Run** `flutter pub run flutter_launcher_icons`
3. **Test** by running the app:
   ```bash
   flutter run
   ```

---

**Version**: 1.0  
**Date**: February 19, 2026  
**Status**: Ready for icon image placement
