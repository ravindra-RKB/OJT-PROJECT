# How to Run the Farmer App

## Prerequisites
1. **Flutter SDK** - Download and install from https://flutter.dev/docs/get-started/install/windows
2. **Android Studio** (for Android development) or **Xcode** (for iOS development on Mac)
3. **VS Code** or **Android Studio** with Flutter extensions (recommended)

## Step 1: Install Flutter Dependencies
Open a terminal/command prompt in the project directory and run:

```bash
flutter pub get
```

This will install all the required packages listed in `pubspec.yaml`.

## Step 2: Check Flutter Setup
Run this command to check if everything is configured correctly:

```bash
flutter doctor
```

Fix any issues that are reported (like missing Android SDK, etc.).

## Step 3: Connect a Device or Start an Emulator

### Option A: Physical Device
- Enable **Developer Options** and **USB Debugging** on your Android phone
- Connect your phone via USB
- Run: `flutter devices` to see connected devices

### Option B: Android Emulator
- Open Android Studio
- Go to **Tools > Device Manager**
- Create/Start an Android Virtual Device (AVD)
- Or run: `flutter emulators --launch <emulator_id>`

## Step 4: Run the App

### Method 1: Using Flutter Command
```bash
flutter run
```

### Method 2: Using VS Code
- Press `F5` or click the "Run" button
- Select your device/emulator

### Method 3: Using Android Studio
- Click the green "Run" button
- Select your device/emulator

## Step 5: Build for Release (Optional)

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

## Troubleshooting

### Issue: "flutter: command not found"
- Make sure Flutter is added to your system PATH
- Restart your terminal after adding Flutter to PATH

### Issue: "No devices found"
- Make sure you have an emulator running or a device connected
- Run `flutter devices` to check available devices

### Issue: Build errors
- Run `flutter clean` to clear build cache
- Run `flutter pub get` again
- Make sure all dependencies are properly installed

### Issue: Firebase errors
- Make sure `google-services.json` is in `android/app/` directory
- Verify Firebase project is set up correctly

## Notes
- The app uses mock data for weather and mandi prices by default
- To use real APIs, update the API keys in:
  - `lib/services/weather_service.dart` (OpenWeatherMap API)
  - `lib/services/mandi_service.dart` (Mandi Price API)
- Farm diary works offline using Hive storage
- All features are functional and ready to use!


