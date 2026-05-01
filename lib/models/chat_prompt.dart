import 'package:flutter/material.dart';

class ChatPrompt {
  const ChatPrompt({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.samplePrompt,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String samplePrompt;
}
