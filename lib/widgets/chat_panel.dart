import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatPanel extends StatelessWidget {
  const ChatPanel({
    super.key,
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.isTyping,
    required this.onSend,
  });

  final List<ChatMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final bool isTyping;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0x1FFFFFFF)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0x18253248), Color(0x10111B2E)],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x32000000),
            blurRadius: 40,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: <Widget>[
                Text(
                  'AI Assistant',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                const _StatusPill(label: 'Live preview', color: Colors.greenAccent),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x12FFFFFF)),
              ),
              child: const Row(
                children: <Widget>[
                  _ModeChip(label: 'Chat', active: true),
                  _ModeChip(label: 'Write', active: false),
                  _ModeChip(label: 'Code', active: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: messages.length + (isTyping ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0 && isTyping) {
                  return const _TypingBubble();
                }

                final int messageIndex = isTyping ? index - 1 : index;
                return _MessageBubble(message: messages[messageIndex]);
              },
            ),
          ),
          _Composer(
            controller: controller,
            onSend: onSend,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(color: color.withOpacity(0.45), blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0x2238BDF8) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final Alignment alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor =
        message.isUser ? const Color(0xFF20445A) : const Color(0x181F2A37);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(message.isUser ? 22 : 8),
              bottomRight: Radius.circular(message.isUser ? 8 : 22),
            ),
            border: Border.all(
              color: message.isUser
                  ? const Color(0x2638BDF8)
                  : const Color(0x16FFFFFF),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message.text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  message.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x181F2A37),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x16FFFFFF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            _TypingDot(),
            SizedBox(width: 6),
            _TypingDot(),
            SizedBox(width: 6),
            _TypingDot(),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white70,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x16FFFFFF)),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add attachment',
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                decoration: const InputDecoration(
                  hintText: 'Ask Nova to design, write, plan, or code...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => onSend(controller.text),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
