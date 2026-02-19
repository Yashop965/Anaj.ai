# Firebase Authentication Setup Guide for Anaj.ai

This guide walks you through setting up Firebase Authentication for your Flutter mobile app.

## Prerequisites

- Flutter SDK installed and updated
- A Firebase project created on [Firebase Console](https://console.firebase.google.com)
- FlutterFire CLI installed (run: `dart pub global activate flutterfire_cli`)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name (e.g., "anaj-ai")
4. Accept the terms and create the project

## Step 2: Configure Firebase for Your App

### Option A: Automatic Setup (Recommended)
```bash
# Navigate to your Flutter project directory
cd mobile_app

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run FlutterFire configuration
flutterfire configure
```

This command will:
- Generate `firebase_options.dart` automatically
- Configure both Android and iOS
- Add necessary dependencies

### Option B: Manual Setup

If automatic setup doesn't work, follow these steps:

#### For Android:
1. Go to Firebase Console → Your Project → Project Settings
2. Add Android app with bundle ID: `com.example.anaj_ai_mobile`
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Update `android/build.gradle`:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### For iOS:
1. Go to Firebase Console → Your Project → Project Settings
2. Add iOS app with bundle ID: `com.example.anajAiMobile`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag & drop `GoogleService-Info.plist` into Xcode
6. Select "Copy items if needed"

## Step 3: Install Dependencies

```bash
# Navigate to mobile_app directory
cd mobile_app

# Get dependencies
flutter pub get
```

## Step 4: Update Firebase Configuration

The `lib/firebase_options.dart` file was created and contains placeholders. If you used the automatic setup, it's already configured. If manual, update the file with your credentials from Firebase Console.

## Step 5: Enable Authentication Methods

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable "Email/Password" authentication
3. Save changes

## Step 6: Test the Setup

```bash
# Clean and build
flutter clean
flutter pub get

# Run the app
flutter run
```

### Test Flow:
1. App should show Login screen
2. Click "Sign up" to create an account
3. Enter email, password, and name
4. After signup, you'll be redirected to Dashboard
5. Click menu (three dots) → Logout to test logout
6. Login with your credentials

## Project Files Created

### Authentication Service
- `lib/logic/firebase_auth_service.dart` - Core Firebase authentication methods

### UI Screens
- `lib/ui/login_view.dart` - Login screen
- `lib/ui/signup_view.dart` - Sign up screen

### Configuration
- `lib/firebase_options.dart` - Firebase configuration (auto-generated)
- `lib/main.dart` - Updated with authentication stream handling

### Updated Dashboard
- `lib/ui/dashboard_view.dart` - Added logout functionality

## Features Implemented

✅ Email/Password Sign Up  
✅ Email/Password Login  
✅ Logout  
✅ Authentication State Management  
✅ Error Handling  
✅ Password Reset Option (Ready to use)  
✅ User Profile Update (Ready to use)  
✅ Session Persistence  
✅ Automatic Redirection (Login → Dashboard)

## Available Methods in FirebaseAuthService

```dart
// Authentication
signUpWithEmail({required String email, required String password})
signInWithEmail({required String email, required String password})
signOut()

// User Management
resetPassword({required String email})
updateUserProfile({required String displayName, required String photoUrl})
deleteUserAccount()

// Properties
currentUser  // Get current logged-in user
authStateChanges  // Stream of auth state changes
```

## Troubleshooting

### "Firebase initialization failed"
- Ensure `firebase_options.dart` is properly configured
- Check that Firebase project exists in console

### "App not showing Login screen"
- Verify Firebase initialization in `main.dart`
- Check that `authStateChanges` stream is working

### Android Build Errors
- Run `flutter clean`
- Update `google-services.json` in `android/app/`
- Ensure gradle plugin is updated

### iOS Build Errors
- Run `flutter clean`
- Run `cd ios && rm -rf Pods && cd ..`
- Run `flutter pub get && flutter run`

## Next Steps (Optional)

1. **Email Verification** - Add email verification after signup
2. **Social Login** - Add Google, Facebook login options
3. **Two-Factor Authentication** - Enhance security
4. **User Profiles** - Store additional user data in Firestore
5. **Biometric Authentication** - Add fingerprint/face recognition

## Security Best Practices

1. Never commit `firebase_options.dart` or `google-services.json` with sensitive data
2. Use Firebase Security Rules to protect data
3. Enable Email verification for production
4. Use strong password requirements
5. Implement rate limiting for login attempts
6. Regular security audits

For more information, visit:
- [Firebase Auth Documentation](https://firebase.flutter.dev/docs/auth/overview)
- [FlutterFire Setup Guide](https://firebase.flutter.dev/docs/overview)
