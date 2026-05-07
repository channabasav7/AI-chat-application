import 'package:flutter/material.dart';
import 'package:ai_chatbot/app.dart' as app;
import 'package:ai_chatbot/services/env_loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ai_chatbot/firebase_options.dart';

export 'package:ai_chatbot/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await EnvLoader.load();
  } catch (e) {
    debugPrint('Warning: Failed to load environment: $e');
  }

  // Ensure Firebase is ready before any Firebase service is used.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  app.bootstrapApp();
}
