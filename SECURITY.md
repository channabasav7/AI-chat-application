# Security Best Practices

A comprehensive guide to securing your AI Chatbot application with Firebase and API integrations.

## Table of Contents
1. [API Key Security](#api-key-security)
2. [Firebase Security](#firebase-security)
3. [Authentication Security](#authentication-security)
4. [Data Protection](#data-protection)
5. [Network Security](#network-security)
6. [Deployment Security](#deployment-security)

---

## API Key Security

### ✅ DO:
- **Store keys in `.env` file** - Never in code
  ```dart
  // ✅ CORRECT
  String apiKey = AppConfig.openaiApiKey;
  ```

- **Add `.env` to `.gitignore`**
  ```
  .env
  .env.local
  .env.*.local
  ```

- **Rotate keys regularly** - Change API keys every 90 days

- **Use environment-specific keys** - Separate keys for dev/staging/production

- **Restrict key permissions** - In cloud console, limit API usage

- **Monitor key usage** - Set up alerts for unusual activity

### ❌ DON'T:
```dart
// ❌ WRONG - Never hardcode API keys
const String API_KEY = "sk-1234567890abcdef";

// ❌ WRONG - Never commit to git
git add .env  // DON'T DO THIS

// ❌ WRONG - Never log sensitive keys
print('API Key: $apiKey');  // DON'T DO THIS

// ❌ WRONG - Never use same key for all environments
final String apiKey = "production_key_123";  // for dev too
```

### API Key Validation
```dart
// lib/config/api_key_validator.dart
class ApiKeyValidator {
  static bool validateOpenAIKey(String key) {
    // OpenAI keys start with 'sk-'
    return key.startsWith('sk-') && key.length > 40;
  }

  static bool validateGoogleKey(String key) {
    return key.isNotEmpty && key.length > 20;
  }

  static void validateAllKeys() {
    if (!ApiKeyValidator.validateOpenAIKey(AppConfig.openaiApiKey)) {
      throw Exception('Invalid OpenAI API key format');
    }
    // Validate other keys...
  }
}
```

---

## Firebase Security

### Firestore Security Rules

**Development Rules** (Only for testing):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ⚠️ ONLY FOR DEVELOPMENT - Opens database to anyone
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Production Rules** (Restrictive):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Conversations subcollection
      match /conversations/{conversationId} {
        allow read, write: if request.auth.uid == userId;
        
        // Messages subcollection
        match /messages/{messageId} {
          allow read, write: if request.auth.uid == userId;
          
          // Validate message structure
          allow create: if request.resource.data.keys().hasAll(['text', 'isUser', 'createdAt']);
          allow update: if false;  // Prevent message editing
          allow delete: if request.resource.data.createdAt > now - duration.value(24, 'h');
        }
      }
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Firebase Authentication Rules

```dart
// Only allow specific sign-up methods
class FirebaseAuthConfig {
  // Enable these methods
  static const bool allowEmailPassword = true;
  static const bool allowGoogle = true;
  static const bool allowGitHub = false;
  
  // Enforce strong passwords
  static const int minPasswordLength = 8;
  static const bool requireSpecialCharacters = true;
}
```

### Disable Public Access
In Firebase Console:
1. Go to **Authentication** → **Settings**
2. **Allow users to sign up** - Only if needed
3. **Email enumeration protection** - Enable
4. **Require strong passwords** - Enable

---

## Authentication Security

### Password Requirements
```dart
class PasswordValidator {
  static const minLength = 8;
  static const minUppercase = 1;
  static const minNumbers = 1;
  static const minSpecialChars = 1;

  static bool isStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*]'));
    final hasMinLength = password.length >= minLength;

    return hasUppercase && hasNumbers && hasSpecialChars && hasMinLength;
  }

  static String getStrengthMessage(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < minLength) return 'At least $minLength characters';
    if (!isStrong(password)) return 'Need uppercase, numbers, and special characters';
    return 'Strong password';
  }
}
```

### Multi-Factor Authentication (Optional)
```dart
// Implement 2FA for sensitive operations
class AuthSecurityService {
  Future<bool> enable2FA(User user) async {
    // Send verification code to email/phone
    // User enters code to enable 2FA
    return true;
  }
}
```

### Session Management
```dart
class SessionManager {
  static const Duration sessionTimeout = Duration(minutes: 30);

  static DateTime? lastActivityTime;

  static void recordActivity() {
    lastActivityTime = DateTime.now();
  }

  static bool isSessionValid() {
    if (lastActivityTime == null) return false;
    final elapsed = DateTime.now().difference(lastActivityTime!);
    return elapsed < sessionTimeout;
  }

  static void signOutIfExpired() {
    if (!isSessionValid()) {
      FirebaseService().signOut();
    }
  }
}
```

---

## Data Protection

### Encryption at Rest
Firebase automatically encrypts data. For additional encryption:

```dart
import 'package:encrypt/encrypt.dart' as encrypt;

class DataEncryption {
  static String encryptData(String data, String key) {
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromBase64(key)));
    final encrypted = encrypter.encrypt(data, iv: encrypt.IV.fromBase64('1234567890123456'));
    return encrypted.base64;
  }

  static String decryptData(String encryptedData, String key) {
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromBase64(key)));
    final decrypted = encrypter.decrypt64(encryptedData, iv: encrypt.IV.fromBase64('1234567890123456'));
    return decrypted;
  }
}
```

### Data Retention Policy
```dart
class DataRetentionPolicy {
  /// Delete old messages (older than 1 year)
  static Future<void> cleanupOldMessages(String userId) async {
    final oneYearAgo = DateTime.now().subtract(Duration(days: 365));
    
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('messages')
        .where('createdAt', isLessThan: oneYearAgo)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
```

### Input Validation
```dart
class InputValidator {
  static String validateEmail(String email) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(email)) {
      throw Exception('Invalid email format');
    }
    return email;
  }

  static String validateMessage(String message) {
    if (message.trim().isEmpty) {
      throw Exception('Message cannot be empty');
    }
    if (message.length > 5000) {
      throw Exception('Message too long (max 5000 characters)');
    }
    return message.trim();
  }

  static String sanitizeInput(String input) {
    // Remove potential XSS/injection attacks
    return input
        .replaceAll('<script>', '')
        .replaceAll('</script>', '')
        .replaceAll('javascript:', '')
        .trim();
  }
}
```

---

## Network Security

### HTTPS Only
```dart
class NetworkConfig {
  // Always use HTTPS
  static const String baseUrl = 'https://api.example.com';  // ✅ HTTPS
  // static const String baseUrl = 'http://api.example.com';  // ❌ Never HTTP
}
```

### Certificate Pinning
```dart
import 'package:dio/dio.dart';

class PinnedHttpClient {
  static Dio createPinnedClient() {
    final dio = Dio();
    
    dio.httpClientAdapter = CertificatePinningHttpClientAdapter(
      allowBadCertificates: false,
      pinnedCertificateDir: 'assets/certificates',
    );
    
    return dio;
  }
}
```

### Request/Response Logging
```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ✅ Log URL and method (not sensitive data)
    print('${options.method} ${options.path}');
    
    // ❌ Never log Authorization headers
    // print('${options.headers}');
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ✅ Log error status
    print('Error ${err.response?.statusCode}');
    
    // ❌ Never log error response body if it contains sensitive data
    handler.next(err);
  }
}
```

---

## Deployment Security

### Pre-deployment Checklist
- [ ] Remove all debug logs
- [ ] Verify `.env` is in `.gitignore`
- [ ] Update Firebase Security Rules to production
- [ ] Enable HTTPS for all API calls
- [ ] Run security audit: `flutter pub outdated`
- [ ] Remove unused dependencies
- [ ] Update all packages to latest versions
- [ ] Run static analysis: `flutter analyze`
- [ ] Enable App Signing in Google Play Console
- [ ] Set up App Attest for iOS
- [ ] Enable SSL pinning for APIs

### Environment Specific Builds
```bash
# Development
flutter run --dart-define=ENVIRONMENT=development

# Staging
flutter build apk --dart-define=ENVIRONMENT=staging

# Production
flutter build apk --dart-define=ENVIRONMENT=production --split-per-abi
```

### Dependency Audit
```bash
# Check for vulnerable packages
flutter pub outdated

# Update packages
flutter pub upgrade

# Check specific package security
flutter pub deps
```

---

## Monitoring & Logging

### Error Tracking
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void setupCrashlytics() {
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
```

### Activity Logging
```dart
class ActivityLog {
  static Future<void> logUserActivity(String action, String userId) async {
    await FirebaseFirestore.instance
        .collection('activity_logs')
        .add({
      'userId': userId,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
      'ipAddress': 'hidden',  // Don't log full IPs
    });
  }
}
```

---

## Incident Response

### If API Key is Compromised
1. **Immediately** go to cloud provider console
2. **Regenerate** the compromised key
3. **Rotate** all dependent services
4. **Monitor** usage for next 24 hours
5. **Update** your `.env` file with new key

### If Data is Breached
1. **Notify** affected users within 72 hours
2. **Investigate** how breach occurred
3. **Update** security rules to prevent recurrence
4. **Force password reset** for affected users
5. **Monitor** accounts for suspicious activity

---

## Security Headers (Web)
```html
<!-- web/index.html -->
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline'">
<meta http-equiv="X-UA-Compatible" content="ie=edge">
<meta http-equiv="X-Content-Type-Options" content="nosniff">
```

---

## Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Firebase Security Best Practices](https://firebase.google.com/support/guides/security-checklist)
- [Dart Security Guidelines](https://dart.dev/guides/security)
- [Flutter Security Documentation](https://flutter.dev/docs/data-and-backend/firebase)

---

## Questions?
If you have security concerns, report them privately to your security team or the Flutter/Firebase teams.

