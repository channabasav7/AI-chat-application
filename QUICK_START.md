# Quick Start Guide: Firebase & API Integration

Get your AI Chatbot up and running with Firebase and API keys in 10 minutes!

## 🚀 Quick Setup (5 Steps)

### Step 1: Update Dependencies
```bash
flutter pub get
```

### Step 2: Configure Environment Variables
```bash
# Copy example to actual file
cp .env.example .env

# Fill in your API keys in .env
# - OPENAI_API_KEY=sk-...
# - GOOGLE_API_KEY=AIza...
# - Other Firebase credentials
```

### Step 3: Set Up Firebase (Choose One)

#### Option A: Firebase with Google Services (Recommended)
1. Go to https://console.firebase.google.com/
2. Create a new project
3. Add your app (Android/iOS)
4. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
5. Place in correct folder:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

#### Option B: Skip Firebase (For Testing Only)
- Modify `main.dart` to comment out Firebase initialization
- Use mock data instead of Firestore

### Step 4: Verify Installation
```bash
flutter analyze
flutter pub get
```

### Step 5: Run the App
```bash
flutter run
```

---

## 📁 File Structure

```
lib/
├── config/
│   └── app_config.dart          # Configuration constants
├── services/
│   ├── firebase_service.dart    # Firebase operations
│   ├── api_service.dart         # External API calls
│   ├── env_loader.dart          # Environment variables
│   ├── chat_service.dart        # Chat business logic
│   ├── firebase_api_examples.dart # Code examples
│   └── README.md                # Services documentation
├── app.dart                     # App root
└── main.dart                    # Entry point
```

---

## 🔑 Environment Variables

Create `.env` file:
```env
OPENAI_API_KEY=your_key_here
GOOGLE_API_KEY=your_key_here
FIREBASE_PROJECT_ID=your_project_id
ENVIRONMENT=development
```

**IMPORTANT**: Never commit `.env` to git! It's in `.gitignore`

---

## 💻 Using the Services

### Save a Chat Message
```dart
import 'package:ai_chatbot/services/firebase_service.dart';

final firebase = FirebaseService();
final userId = firebase.getCurrentUser()?.uid;

await firebase.saveChatMessage(
  userId: userId!,
  conversationId: 'conv123',
  text: 'Hello!',
  isUser: true,
  timestamp: DateTime.now().toString(),
);
```

### Call OpenAI API
```dart
import 'package:ai_chatbot/services/api_service.dart';

final api = ApiService();
final response = await api.callOpenAI('What is Flutter?');
print(response);
```

### Get Real-time Chat Messages
```dart
firebase.getChatMessages(
  userId: userId!,
  conversationId: 'conv123',
).listen((snapshot) {
  for (var doc in snapshot.docs) {
    print('Message: ${doc['text']}');
  }
});
```

---

## 🔐 Security Checklist

- [ ] `.env` is in `.gitignore`
- [ ] Never hardcode API keys
- [ ] Use HTTPS for all API calls
- [ ] Review Firebase Security Rules
- [ ] Enable app signing for Android
- [ ] Test with real Firebase project

---

## 🐛 Troubleshooting

### "Firebase not initialized"
```
❌ Error: No Firebase app found
✅ Solution: Check main.dart has await FirebaseService().initialize()
```

### "API Key not found"
```
❌ Error: API Key "OPENAI_API_KEY" not found
✅ Solution: Create .env file and populate with actual keys
```

### "google-services.json not found" (Android)
```
❌ Error: android/app/google-services.json not found
✅ Solution: Download from Firebase Console and place in android/app/
```

### Build errors after adding Firebase
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 Next Steps

1. **Read Full Guides**:
   - [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md) - Complete Firebase setup
   - [SECURITY.md](SECURITY.md) - Security best practices
   - [lib/services/README.md](lib/services/README.md) - Service documentation

2. **View Code Examples**:
   - [lib/services/firebase_api_examples.dart](lib/services/firebase_api_examples.dart)

3. **Customize for Your Needs**:
   - Add user authentication UI
   - Implement chat interface
   - Connect to real APIs

---

## 🆘 Still Having Issues?

1. Check the detailed guides above
2. Review error messages carefully
3. Verify all files are in correct locations
4. Check Firebase Console permissions
5. Ensure API keys have proper scopes

---

## ✨ Key Features Enabled

✅ Firebase Authentication (Email/Password)
✅ Cloud Firestore (Real-time Database)
✅ OpenAI API Integration
✅ Environment Variable Management
✅ Secure API Key Handling
✅ Error Handling & Logging
✅ Real-time Chat Updates

---

## 📞 Support

For issues:
- Check [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md) troubleshooting
- Review [SECURITY.md](SECURITY.md) for security concerns
- Check Firebase documentation: https://firebase.flutter.dev/

Happy coding! 🎉
