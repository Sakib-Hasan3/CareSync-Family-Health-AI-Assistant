# Firebase Setup Instructions for CareSync

## Current Status
✅ FlutterFire CLI is installed
✅ Firebase dependencies are added to pubspec.yaml
✅ Firebase initialization code is added to main.dart
❌ Firebase project configuration needed

## Next Steps

### Option 1: Install Node.js and Firebase CLI (Recommended)

1. **Download Node.js**:
   - Go to https://nodejs.org/en/download/
   - Download the LTS version for Windows
   - Install it following the setup wizard
   - Restart your terminal/PowerShell

2. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

3. **Login to Firebase**:
   ```bash
   firebase login
   ```

4. **Configure Firebase for Flutter**:
   ```bash
   flutterfire configure
   ```

### Option 2: Manual Setup (If you can't install Node.js)

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com/
   - Click "Create a project"
   - Name it "caresync" or any name you prefer
   - Enable Google Analytics (optional)

2. **Add Flutter App to Project**:
   - In Firebase Console, click "Add app" and select Flutter
   - Follow the setup instructions for each platform (Android/iOS/Web)

3. **Download Configuration Files**:
   - For Android: Download `google-services.json` → place in `android/app/`
   - For iOS: Download `GoogleService-Info.plist` → place in `ios/Runner/`
   - For Web: Copy the web configuration keys

4. **Update firebase_options.dart**:
   - Replace the placeholder values in `lib/firebase_options.dart`
   - Use the actual keys from your Firebase project

### Option 3: Use FlutterFire CLI Directly

If you have a Google account and can access Firebase Console:

1. **Make sure FlutterFire CLI is in PATH**:
   ```bash
   $env:PATH += ";C:\Users\Pacific BD\AppData\Local\Pub\Cache\bin"
   ```

2. **Configure Firebase**:
   ```bash
   flutterfire configure
   ```

3. **Follow the prompts** to select/create a Firebase project

## Firebase Services to Enable

Once your project is set up, enable these services in Firebase Console:

1. **Authentication** (for user login)
   - Go to Authentication → Sign-in method
   - Enable Email/Password and Google sign-in

2. **Firestore Database** (for storing app data)
   - Go to Firestore Database → Create database
   - Start in test mode

3. **Storage** (for file uploads)
   - Go to Storage → Get started
   - Start in test mode

4. **Cloud Messaging** (for notifications)
   - Already enabled by default

## Testing Firebase Connection

After setup, test the connection:

```bash
flutter run
```

The app should start without Firebase errors.

## Troubleshooting

- If you get dependency conflicts, run: `flutter pub get`
- If you get build errors, run: `flutter clean && flutter pub get`
- Make sure all configuration files are in the correct locations