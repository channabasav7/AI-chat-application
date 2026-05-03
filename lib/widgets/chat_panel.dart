import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatPanel extends StatefulWidget {
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
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: const Color(0x22FFFFFF)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0x1F25354E), Color(0x12101A29)],
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x42000000),
                blurRadius: 44,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              children: <Widget>[
                const Positioned(
                  top: -60,
                  right: -40,
                  child: _PanelGlow(color: Color(0x2B38BDF8), size: 180),
                ),
                const Positioned(
                  bottom: 150,
                  left: -60,
                  child: _PanelGlow(color: Color(0x2238D7A4), size: 150),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'AI Assistant',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Design, write, plan, or code with a focused chat workspace.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const _StatusPill(
                            label: 'Live preview',
                            color: Colors.greenAccent,
                          ),
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
                        controller: widget.scrollController,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount:
                            widget.messages.length + (widget.isTyping ? 1 : 0),
                        separatorBuilder:
                          (BuildContext context, int index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0 && widget.isTyping) {
                            return const _TypingBubble();
                          }

                          final int messageIndex =
                              widget.isTyping ? index - 1 : index;
                          return _AnimatedMessageBubble(
                            message: widget.messages[messageIndex],
                            index: messageIndex,
                          );
                        },
                      ),
                    ),
                    _Composer(
                      controller: widget.controller,
                      onSend: widget.onSend,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelGlow extends StatelessWidget {
  const _PanelGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, Colors.transparent],
          ),
        ),
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
                BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 10),
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

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: message.isUser
                  ? <Color>[const Color(0xFF2E6D92), const Color(0xFF214C69)]
                  : <Color>[const Color(0x25273443), const Color(0x1418222E)],
            ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(message.isUser ? 22 : 8),
              bottomRight: Radius.circular(message.isUser ? 8 : 22),
            ),
            border: Border.all(
              color: message.isUser
                  ? const Color(0x4038BDF8)
                  : const Color(0x16FFFFFF),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: message.isUser
                    ? const Color(0x1F38BDF8)
                    : const Color(0x12000000),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ),
    );
  }
}

class _AnimatedMessageBubble extends StatelessWidget {
  const _AnimatedMessageBubble({required this.message, required this.index});

  final ChatMessage message;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Duration duration =
        Duration(milliseconds: 220 + (index * 30).clamp(0, 160));
    final double direction = message.isUser ? 1.0 : -1.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 18 * direction, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: _MessageBubble(message: message),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x1A1F2A37),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x16FFFFFF)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _TypingDot(delay: 0),
              SizedBox(width: 6),
              _TypingDot(delay: 1),
              SizedBox(width: 6),
              _TypingDot(delay: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});

  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _controller.value = widget.delay / 3;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double scale = 0.72 + (_controller.value * 0.32);
        final double opacity = 0.55 + (_controller.value * 0.45);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white70,
          shape: BoxShape.circle,
        ),
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
          color: const Color(0x19FFFFFF),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x18FFFFFF)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add attachment',
              ),
            ),
            const SizedBox(width: 4),
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
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF38BDF8), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: FilledButton(
                onPressed: () => onSend(controller.text),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
