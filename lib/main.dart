import 'package:flutter/material.dart';
import 'package:ai_chatbot/app.dart' as app;
import 'package:ai_chatbot/services/env_loader.dart';
import 'package:ai_chatbot/services/firebase_service.dart';

export 'package:ai_chatbot/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await EnvLoader.load();
  
  // Initialize Firebase
  final firebaseService = FirebaseService();
  try {
    await firebaseService.initialize();
  } catch (e) {
    debugPrint('Warning: Firebase initialization failed: $e');
    // App will still run without Firebase
  }
  
  app.bootstrapApp();
}
