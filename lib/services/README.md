# Services Documentation

This directory contains all the business logic and external service integrations for the AI Chatbot application.

## Files Overview

### `firebase_service.dart`
Handles all Firebase operations including:
- **Authentication**: Sign up, sign in, sign out
- **Firestore**: Chat messages, conversations, user profiles
- **Real-time data**: Stream listeners for live updates

**Key Methods:**
- `signUpWithEmail(email, password)`
- `signInWithEmail(email, password)`
- `saveChatMessage(...)`
- `getChatMessages(...)`
- `createConversation(...)`
- `getUserConversations(...)`

### `api_service.dart`
Manages HTTP requests to external APIs:
- **OpenAI**: ChatGPT API calls
- **Google APIs**: Places, Translate, etc.
- **Generic HTTP**: GET, POST, PUT, DELETE methods

**Key Methods:**
- `callOpenAI(prompt)`
- `callGoogleAPI(endpoint, params)`
- `get(url, headers, queryParameters)`
- `post(url, data, headers)`

### `chat_service.dart`
Business logic for chat operations:
- Sample messages and prompts
- Chat UI data preparation

### `env_loader.dart`
Environment variable management:
- Loads variables from `.env` file
- Provides access to API keys securely

**Key Methods:**
- `load()`
- `getApiKey(key)`
- `isKeySet(key)`

### `app_config.dart`
Configuration constants and settings:
- API key references
- Environment checking
- Theme configurations

---

## Singleton Pattern

All services use the **Singleton pattern** to ensure only one instance exists:

```dart
// Firebase Service (Singleton)
final firebaseService = FirebaseService();
final firebaseService2 = FirebaseService();
// firebaseService and firebaseService2 are the same instance
```

This ensures consistent state and efficient resource usage.

---

## Usage Examples

Refer to `firebase_api_examples.dart` for comprehensive code examples:

```dart
// Authentication
await FirebaseService().signUpWithEmail(email, password);

// Firestore
await FirebaseService().saveChatMessage(...);

// API
final response = await ApiService().callOpenAI(prompt);
```

---

## Initialization

Services are initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EnvLoader.load();
  await FirebaseService().initialize();
  
  app.bootstrapApp();
}
```

---

## Error Handling

All services include error handling:

```dart
try {
  await firebaseService.saveChatMessage(...);
} catch (e) {
  print('Error: $e');
}
```

---

## Best Practices

1. **Always initialize** services in `main()` before using them
2. **Use streams** for real-time data: `firebaseService.getChatMessages(...).listen(...)`
3. **Catch exceptions** properly for each service
4. **Never hardcode API keys** - use `.env` file
5. **Dispose resources** when not needed
6. **Use async/await** for cleaner code
7. **Validate inputs** before sending to APIs/Database

---

## Adding New Services

To add a new service:

1. Create a new file: `lib/services/my_service.dart`
2. Implement singleton pattern
3. Add error handling
4. Document public methods
5. Add examples to `firebase_api_examples.dart`

---

## Testing

For unit tests, create mocks:

```dart
class MockFirebaseService extends FirebaseService {
  @override
  Future<void> initialize() async {
    // Mock implementation
  }
}
```

---

## Common Issues

**Issue**: "API Key not found"
- **Solution**: Check `.env` file exists and `EnvLoader.load()` is called

**Issue**: "Firebase not initialized"
- **Solution**: Ensure `FirebaseService().initialize()` is called in `main()`

**Issue**: "Permission denied" on Firestore
- **Solution**: Check Firebase Security Rules in Firebase Console

---

## See Also

- [FIREBASE_SETUP_GUIDE.md](../FIREBASE_SETUP_GUIDE.md) - Complete setup instructions
- [SECURITY.md](../SECURITY.md) - Security best practices
- [firebase_api_examples.dart](./firebase_api_examples.dart) - Code examples
