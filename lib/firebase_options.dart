import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for iOS/macOS.',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for desktop.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for Fuchsia.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtBQp52HsybeIMbXBkukG5vc5PmYAObm8',
    appId: '1:767798087750:android:5791d93e970344cf61ba47',
    messagingSenderId: '767798087750',
    projectId: 'ai-chatbot-80b84',
    storageBucket: 'ai-chatbot-80b84.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCupayIJ7ujKGBxfP4h7EQqAzTD6djl1XI',
    appId: '1:767798087750:web:e0b6956f6c6bd99c61ba47',
    messagingSenderId: '767798087750',
    projectId: 'ai-chatbot-80b84',
    authDomain: 'ai-chatbot-80b84.firebaseapp.com',
    storageBucket: 'ai-chatbot-80b84.firebasestorage.app',
    measurementId: 'G-P5MHFH305M',
  );
}
