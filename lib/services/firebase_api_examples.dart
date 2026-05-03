import 'package:flutter/material.dart';
import 'package:ai_chatbot/services/firebase_service.dart';
import 'package:ai_chatbot/services/api_service.dart';

/// Quick reference examples for using Firebase and API Services
/// 
/// This file demonstrates common usage patterns for:
/// - Firebase Authentication
/// - Firestore Data Operations
/// - External API Calls

class FirebaseApiExamples {
  static final firebaseService = FirebaseService();
  static final apiService = ApiService();

  // ===== AUTHENTICATION EXAMPLES =====

  /// Example: Sign up a new user
  static Future<void> exampleSignUp() async {
    try {
      final credential = await firebaseService.signUpWithEmail(
        'user@example.com',
        'SecurePassword123!',
      );
      print('User created: ${credential.user?.uid}');
    } catch (e) {
      print('Sign up error: $e');
    }
  }

  /// Example: Sign in existing user
  static Future<void> exampleSignIn() async {
    try {
      final credential = await firebaseService.signInWithEmail(
        'user@example.com',
        'SecurePassword123!',
      );
      print('User signed in: ${credential.user?.uid}');
    } catch (e) {
      print('Sign in error: $e');
    }
  }

  /// Example: Check if user is authenticated
  static void exampleCheckAuth() {
    if (firebaseService.isUserAuthenticated()) {
      final user = firebaseService.getCurrentUser();
      print('Current user: ${user?.email}');
    } else {
      print('User not authenticated');
    }
  }

  // ===== FIRESTORE DATA EXAMPLES =====

  /// Example: Create a new conversation
  static Future<void> exampleCreateConversation() async {
    try {
      final userId = firebaseService.getCurrentUser()?.uid;
      if (userId == null) return;

      final conversationId = await firebaseService.createConversation(
        userId: userId,
        title: 'My First Chat',
      );
      print('Conversation created: $conversationId');
    } catch (e) {
      print('Error creating conversation: $e');
    }
  }

  /// Example: Save a chat message
  static Future<void> exampleSaveMessage() async {
    try {
      final userId = firebaseService.getCurrentUser()?.uid;
      if (userId == null) return;

      await firebaseService.saveChatMessage(
        userId: userId,
        conversationId: 'conv123',
        text: 'Hello, how are you?',
        isUser: true,
        timestamp: DateTime.now().toString(),
      );
      print('Message saved successfully');
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  /// Example: Get messages from a conversation (real-time)
  static void exampleGetMessages() {
    final userId = firebaseService.getCurrentUser()?.uid;
    if (userId == null) return;

    firebaseService.getChatMessages(
      userId: userId,
      conversationId: 'conv123',
    ).listen(
      (snapshot) {
        for (var doc in snapshot.docs) {
          print('Message: ${doc['text']}');
        }
      },
      onError: (e) => print('Error: $e'),
    );
  }

  /// Example: Get all user conversations
  static void exampleGetConversations() {
    final userId = firebaseService.getCurrentUser()?.uid;
    if (userId == null) return;

    firebaseService.getUserConversations(userId).listen(
      (snapshot) {
        for (var doc in snapshot.docs) {
          print('Conversation: ${doc['title']}');
        }
      },
      onError: (e) => print('Error: $e'),
    );
  }

  /// Example: Update conversation title
  static Future<void> exampleUpdateConversation() async {
    try {
      final userId = firebaseService.getCurrentUser()?.uid;
      if (userId == null) return;

      await firebaseService.updateConversationTitle(
        userId: userId,
        conversationId: 'conv123',
        newTitle: 'Updated Chat Title',
      );
      print('Conversation updated');
    } catch (e) {
      print('Error updating conversation: $e');
    }
  }

  /// Example: Delete a conversation
  static Future<void> exampleDeleteConversation() async {
    try {
      final userId = firebaseService.getCurrentUser()?.uid;
      if (userId == null) return;

      await firebaseService.deleteConversation(
        userId: userId,
        conversationId: 'conv123',
      );
      print('Conversation deleted');
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }

  /// Example: Save user profile
  static Future<void> exampleSaveProfile() async {
    try {
      final userId = firebaseService.getCurrentUser()?.uid;
      if (userId == null) return;

      await firebaseService.saveUserProfile(
        userId: userId,
        profileData: {
          'displayName': 'John Doe',
          'email': 'john@example.com',
          'avatar': 'https://example.com/avatar.jpg',
          'theme': 'dark',
        },
      );
      print('Profile saved');
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  /// Example: Get user profile
  static Future<void> exampleGetProfile() async {
    try {
      final userId = firebaseService.getCurrentUser()?.uid;
      if (userId == null) return;

      final doc = await firebaseService.getUserProfile(userId);
      if (doc.exists) {
        print('Profile: ${doc.data()}');
      }
    } catch (e) {
      print('Error getting profile: $e');
    }
  }

  // ===== API EXAMPLES =====

  /// Example: Call OpenAI API
  static Future<void> exampleCallOpenAI() async {
    try {
      final response = await apiService.callOpenAI(
        'What is Flutter and why should I use it?',
      );
      print('OpenAI Response: $response');
    } catch (e) {
      print('Error calling OpenAI: $e');
    }
  }

  /// Example: Generic GET request
  static Future<void> exampleGetRequest() async {
    try {
      final data = await apiService.get(
        url: 'https://api.example.com/data',
        headers: {'Authorization': 'Bearer token123'},
      );
      print('Response: $data');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example: Generic POST request
  static Future<void> examplePostRequest() async {
    try {
      final data = await apiService.post(
        url: 'https://api.example.com/save',
        data: {
          'name': 'John',
          'email': 'john@example.com',
        },
        headers: {'Authorization': 'Bearer token123'},
      );
      print('Response: $data');
    } catch (e) {
      print('Error: $e');
    }
  }

  // ===== WIDGET EXAMPLE =====

  /// Example Widget: Chat message display with Firebase data
  static Widget exampleChatWidget(BuildContext context) {
    final userId = firebaseService.getCurrentUser()?.uid;
    if (userId == null) {
      return const Center(child: Text('Please sign in first'));
    }

    return StreamBuilder(
      stream: firebaseService.getChatMessages(
        userId: userId,
        conversationId: 'conv123',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return ListTile(
              title: Text(doc['text']),
              subtitle: Text(doc['isUser'] ? 'You' : 'Assistant'),
            );
          },
        );
      },
    );
  }
}
