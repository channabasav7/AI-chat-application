# Firebase & API Integration Setup Guide

## Overview
This guide helps you set up Firebase for data storage and API keys management for your AI Chatbot application.

## Prerequisites
- Flutter installed and up-to-date
- Google account for Firebase
- API keys for services you plan to use (OpenAI, Google, etc.)

---

## Step 1: Firebase Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter your project name (e.g., "ai-chatbot")
4. Follow the setup wizard
5. Enable Google Analytics (optional)

### 1.2 Enable Services
In Firebase Console, enable:
- **Authentication** (Email/Password, Google Sign-In)
- **Cloud Firestore** (for data storage)
- **Cloud Storage** (optional, for file uploads)

### 1.3 Download Configuration Files

#### For Android:
1. In Firebase Console, go to Project Settings → Your apps
2. Select Android and register your app
3. Download `google-services.json`
4. Place it in `android/app/`

#### For iOS:
1. In Firebase Console, register iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/` using Xcode

#### For Web:
```dart
// Add to web/index.html in <script> tag
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-app.js";
  
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  
  initializeApp(firebaseConfig);
</script>
```

---

## Step 2: Environment Variables Setup

### 2.1 Configure .env File
1. Copy `.env.example` to `.env`
2. Fill in your API keys:

```env
# API Keys
OPENAI_API_KEY=your_actual_openai_api_key_here
GOOGLE_API_KEY=your_actual_google_api_key_here

# Firebase Configuration (from Google Cloud Console)
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_MESSAGING_SENDER_ID=your_firebase_sender_id
FIREBASE_APP_ID=your_firebase_app_id

# Environment
ENVIRONMENT=development
```

### 2.2 Important: .gitignore
Make sure `.env` is in your `.gitignore`:
```
.env
.env.local
```

---

## Step 3: Installing Dependencies

Run the following command to get all dependencies:

```bash
flutter pub get
```

This installs:
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Database
- `firebase_auth` - Authentication
- `http` / `dio` - HTTP client
- `flutter_dotenv` - Environment variables

---

## Step 4: Obtaining API Keys

### OpenAI API Key
1. Visit [OpenAI Platform](https://platform.openai.com/)
2. Create an account or sign in
3. Go to API Keys section
4. Create a new API key
5. Copy and paste into `.env` as `OPENAI_API_KEY`

### Google API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable the APIs you need (Places, Translate, etc.)
4. Create OAuth 2.0 credentials (API key)
5. Copy and paste into `.env` as `GOOGLE_API_KEY`

---

## Step 5: Using Firebase Services

### Example: Authentication
```dart
final firebaseService = FirebaseService();

// Sign up
await firebaseService.signUpWithEmail('user@example.com', 'password123');

// Sign in
await firebaseService.signInWithEmail('user@example.com', 'password123');

// Get current user
User? user = firebaseService.getCurrentUser();

// Sign out
await firebaseService.signOut();
```

### Example: Saving Chat Messages
```dart
await firebaseService.saveChatMessage(
  userId: 'user123',
  conversationId: 'conv456',
  text: 'Hello, how are you?',
  isUser: true,
  timestamp: DateTime.now().toString(),
);
```

### Example: Getting Chat History
```dart
Stream<QuerySnapshot> messages = firebaseService.getChatMessages(
  userId: 'user123',
  conversationId: 'conv456',
);

// Listen to messages in real-time
messages.listen((snapshot) {
  for (var doc in snapshot.docs) {
    print(doc['text']);
  }
});
```

---

## Step 6: Using API Services

### Example: Calling OpenAI API
```dart
final apiService = ApiService();

String response = await apiService.callOpenAI('What is Flutter?');
print(response);
```

### Example: Generic HTTP Request
```dart
final data = await apiService.post(
  url: 'https://api.example.com/endpoint',
  data: {'key': 'value'},
);
```

---

## Step 7: Build & Deploy

### Development
```bash
flutter run
```

### Production Build
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

---

## Troubleshooting

### Firebase not initializing?
- Check if `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is properly placed
- Ensure Firebase Console has the correct package names for your app

### API keys not working?
- Verify `.env` file is in project root
- Check if API key has correct permissions in cloud console
- Ensure `.env` is added to `pubspec.yaml` assets

### Build errors with Firebase?
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### "The default FirebaseApp is not initialized" error?
- Ensure `FirebaseService().initialize()` is called in `main()` before `runApp()`

---

## Security Best Practices

1. **Never commit `.env` file** to version control
2. **Use Firebase Security Rules** to protect your data
3. **Enable authentication** before allowing database access
4. **Rotate API keys** periodically
5. **Use environment-specific keys** for development vs production
6. **Enable HTTPS** for all API calls
7. **Validate all user inputs** before sending to API/Database

---

## Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Cloud Firestore Docs](https://firebase.google.com/docs/firestore)
- [Flutter Dotenv Package](https://pub.dev/packages/flutter_dotenv)
- [Dio HTTP Client](https://pub.dev/packages/dio)

---

## Next Steps

1. Update your UI components to use `FirebaseService` and `ApiService`
2. Implement real-time chat synchronization with Firestore
3. Add user authentication screens
4. Set up Cloud Functions for server-side logic
5. Configure Firebase Security Rules for your database

