import 'package:flutter/material.dart';

import '../models/chat_prompt.dart';
import 'chat_prompt_card.dart';

class ChatSidebar extends StatelessWidget {
  const ChatSidebar({
    super.key,
    required this.prompts,
    required this.onPromptSelected,
  });

  final List<ChatPrompt> prompts;
  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x14253248),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x1FFFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Jump into a prompt that feels close to your next task.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 18),
          for (final ChatPrompt prompt in prompts) ...<Widget>[
            ChatPromptCard(
              prompt: prompt,
              onTap: () => onPromptSelected(prompt.samplePrompt),
            ),
            const SizedBox(height: 12),
          ],
          const Spacer(),
          const _MetricRow(label: 'Average response', value: '0.9s'),
          const SizedBox(height: 10),
          const _MetricRow(label: 'Messages today', value: '24'),
          const SizedBox(height: 10),
          const _MetricRow(label: 'Creativity mode', value: 'Balanced'),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
