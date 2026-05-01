import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/chat_prompt.dart';

class ChatService {
  const ChatService();

  List<ChatMessage> initialMessages() {
    return <ChatMessage>[
      const ChatMessage(
        text:
            'Welcome to Nova AI. I can help you brainstorm ideas, draft copy, plan projects, and build polished Flutter interfaces.',
        isUser: false,
        time: '09:30',
      ),
      const ChatMessage(
        text: 'Design me a clean AI assistant screen with glassmorphism and smooth spacing.',
        isUser: true,
        time: '09:31',
      ),
      const ChatMessage(
        text:
            'Use layered gradients, readable cards, and a strong composer bar. Keep it responsive for mobile and desktop.',
        isUser: false,
        time: '09:31',
      ),
    ];
  }

  List<ChatPrompt> quickPrompts() {
    return const <ChatPrompt>[
      ChatPrompt(
        title: 'Brainstorm',
        subtitle: 'Product names and positioning',
        icon: Icons.auto_awesome_rounded,
        samplePrompt: 'Brainstorm product names and positioning',
      ),
      ChatPrompt(
        title: 'Write',
        subtitle: 'A clear launch announcement',
        icon: Icons.edit_rounded,
        samplePrompt: 'Write a clear launch announcement',
      ),
      ChatPrompt(
        title: 'Code',
        subtitle: 'Flutter UI with dark glass panels',
        icon: Icons.code_rounded,
        samplePrompt: 'Code a Flutter UI with dark glass panels',
      ),
    ];
  }

  String buildResponse(String prompt) {
    final String normalized = prompt.toLowerCase();

    if (normalized.contains('flutter') || normalized.contains('ui')) {
      return 'I would use a layered background, elevated glass cards, and a constrained message column with desktop-aware padding.';
    }
    if (normalized.contains('brainstorm') || normalized.contains('name')) {
      return 'Here are a few directions: Nova, Pulse, Orbit, and Beacon. I can refine them into a sharper brand style if you want.';
    }
    if (normalized.contains('write') || normalized.contains('announcement')) {
      return 'Drafting a concise launch note with a clear hook, one primary benefit, and a direct call to action.';
    }

    return 'That is a strong direction. I can refine the structure, visual hierarchy, and tone to make it feel more premium.';
  }

  String currentTimeLabel(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
