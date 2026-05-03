# Troubleshooting Guide

Common issues and solutions when working with Firebase and APIs.

## Firebase Issues

### Issue: "The default FirebaseApp is not initialized"

**Cause**: Firebase initialization hasn't been called before using services

**Solution**:
```dart
// main.dart - Make sure this is included:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseService().initialize();  // ✅ This line is essential
  
  app.bootstrapApp();
}
```

---

### Issue: "google-services.json not found" (Android)

**Cause**: Firebase configuration file missing from Android project

**Solution**:
1. Go to Firebase Console
2. Select your project
3. Go to Project Settings → Your apps → Android
4. Click "Download google-services.json"
5. Place file in: `android/app/google-services.json`

```bash
# Verify file is in correct location:
ls android/app/google-services.json
```

---

### Issue: "GoogleService-Info.plist not found" (iOS)

**Cause**: Firebase configuration file missing from iOS project

**Solution**:
1. Go to Firebase Console → Project Settings → iOS app
2. Download `GoogleService-Info.plist`
3. Open `ios/Runner.xcworkspace` in Xcode
4. Right-click Runner project → Add Files
5. Select the downloaded `.plist` file
6. Make sure "Copy items if needed" is checked

---

### Issue: "Permission denied" when writing to Firestore

**Cause**: Firestore Security Rules don't allow the operation

**Solution**: Update Firebase Security Rules in Firebase Console:

```javascript
// Go to Firestore → Rules tab
// For development (temporary):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Then click "Publish"

**IMPORTANT**: Update to production rules before deploying!

---

### Issue: Authentication fails with "INVALID_LOGIN_CREDENTIALS"

**Cause**: Wrong email/password combination

**Solution**:
1. Verify email and password are correct
2. Check if user account exists in Firebase Console
3. Verify email is confirmed (if required)
4. Check password isn't expired/locked

---

### Issue: Firestore takes too long to respond

**Cause**: Too many documents being queried

**Solution**:
1. Add pagination: `.limit(20)`
2. Add filtering: `.where('userId', isEqualTo: userId)`
3. Add indexing in Firestore (Firebase Console will suggest)

```dart
// Better query:
firestore
    .collection('messages')
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .limit(20)
    .snapshots();
```

---

## API Key Issues

### Issue: "Invalid API Key" or "Unauthorized"

**Cause**: API key is incorrect, expired, or lacks permissions

**Solution**:
1. Verify `.env` file contains correct key
2. Check `.env` file is in project root
3. Verify API key hasn't expired in cloud console
4. Check API key has required permissions:
   - OpenAI: Chat Completions permission
   - Google: APIs enabled in Cloud Console

```bash
# Verify .env file exists:
cat .env

# Check file is readable:
ls -la .env
```

---

### Issue: "API Key not found in environment variables"

**Cause**: `.env` not being loaded or key not set

**Solution**:
```dart
// In main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EnvLoader.load();  // ✅ Make sure this is called
  
  app.bootstrapApp();
}

// In services, use:
final key = AppConfig.openaiApiKey;  // ✅ This reads from .env
```

---

### Issue: "Request timeout" from API

**Cause**: API is slow or network is unstable

**Solution**:
```dart
// Increase timeout in ApiService:
_dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 60),  // ✅ Increased
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  ),
);
```

Or add retry logic:
```dart
Future<String> callOpenAIWithRetry(String prompt, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await apiService.callOpenAI(prompt);
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 2 << i));  // Exponential backoff
    }
  }
  throw Exception('Failed after $maxRetries attempts');
}
```

---

### Issue: "Rate limit exceeded"

**Cause**: Too many API requests in short time

**Solution**:
```dart
import 'package:throttle/throttle.dart';

// Create throttled function
final throttledCall = throttle(
  (String prompt) => apiService.callOpenAI(prompt),
  Duration(seconds: 2),  // Allow 1 call every 2 seconds
);

// Use it:
await throttledCall(userPrompt);
```

---

## Dependency Issues

### Issue: "Dependency on cloud_firestore from git failed"

**Cause**: Version conflicts or platform-specific issues

**Solution**:
```bash
# Clean and reinstall:
flutter clean
flutter pub get

# Or update to specific version:
flutter pub upgrade cloud_firestore
```

---

### Issue: "Unresolved reference" in IDE

**Cause**: IDE cache is stale

**Solution**:
```bash
# Restart IDE and run:
flutter pub get
flutter pub upgrade
flutter analyze
```

---

### Issue: Build fails with "Plugin build failed"

**Cause**: Firebase plugin not properly installed

**Solution**:
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

## Development Build Issues

### Issue: App crashes on startup

**Cause**: Initialization error

**Solution**:
1. Check console for error messages
2. Add try-catch around initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await EnvLoader.load();
    await FirebaseService().initialize();
  } catch (e) {
    print('Initialization error: $e');
    // Continue anyway for testing
  }
  
  app.bootstrapApp();
}
```

---

### Issue: Hot reload doesn't work

**Cause**: Firebase/Firestore requires full restart

**Solution**:
```bash
# Full restart instead of hot reload:
flutter run --no-fast-start

# Or press 'R' in terminal (full restart)
```

---

### Issue: Emulator too slow

**Cause**: Firestore emulator consumes resources

**Solution**:
```bash
# Stop emulator and restart:
flutter emulators --launch <emulator_name>

# Or use physical device for testing
```

---

## Network Issues

### Issue: Connection refused to Firestore

**Cause**: Running against production but network blocked

**Solution**:
```dart
// Use local emulator for development:
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

---

### Issue: "Bad certificate" error

**Cause**: SSL certificate validation failure

**Solution**:
```dart
// For development only:
HttpOverrides.global = MyHttpOverrides();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

⚠️ **Never use in production!**

---

## Testing Issues

### Issue: Tests fail with Firebase initialization

**Cause**: Firebase needs mock for unit tests

**Solution**:
```dart
// Create mock:
class MockFirebaseService extends FirebaseService {
  @override
  Future<void> initialize() async {
    // Mock implementation
  }
}

// Use in tests:
void main() {
  final mockFirebase = MockFirebaseService();
  // Test with mock
}
```

---

## Performance Issues

### Issue: App is slow/laggy with Firestore

**Cause**: Too many real-time listeners

**Solution**:
```dart
// Bad: Multiple listeners created repeatedly
ListView.builder(
  itemBuilder: (context, index) {
    return StreamBuilder(
      stream: firebase.getChatMessages(...),  // ❌ Creates many listeners
      builder: ...
    );
  },
)

// Good: Single listener, shared data
StreamBuilder(
  stream: firebase.getChatMessages(...),  // ✅ Single listener
  builder: (context, snapshot) {
    return ListView.builder(
      itemCount: snapshot.data?.docs.length ?? 0,
      itemBuilder: (context, index) {
        // Use shared snapshot data
      },
    );
  },
)
```

---

## Debugging Tips

### Enable Firebase Debug Logging
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable debug logging
  await Firebase.initializeApp(
    options: FirebaseOptions(
      // your options...
      apiKey: 'YOUR_KEY',
    ),
  );
  
  app.bootstrapApp();
}
```

### Check API Key Status
```dart
void checkApiKeys() {
  print('OpenAI Key Set: ${EnvLoader.isKeySet('OPENAI_API_KEY')}');
  print('Google Key Set: ${EnvLoader.isKeySet('GOOGLE_API_KEY')}');
  print('Environment: ${AppConfig.environment}');
}
```

### Monitor Firestore Usage
In Firebase Console:
1. Go to Firestore → Usage
2. Check read/write/delete counts
3. Identify high-usage operations

---

## Getting Help

1. **Check logs**: Look for error messages in console
2. **Search issues**: GitHub repos for similar problems
3. **Firebase docs**: https://firebase.google.com/docs
4. **Flutter docs**: https://flutter.dev/docs
5. **Stack Overflow**: Search with error message

---

## Still Stuck?

Follow this checklist:
- [ ] All files in correct locations
- [ ] `.env` file has valid API keys
- [ ] Firebase Security Rules allow operation
- [ ] Internet connection is active
- [ ] Firebase project exists and is active
- [ ] Dependencies are installed (`flutter pub get`)
- [ ] App has been rebuilt (`flutter clean && flutter run`)
- [ ] Check console for detailed error message

If all else fails, create a minimal test case and debug from there!
