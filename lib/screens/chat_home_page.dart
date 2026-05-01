import 'dart:async';

import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/chat_prompt.dart';
import '../services/chat_service.dart';
import '../widgets/chat_background.dart';
import '../widgets/chat_panel.dart';
import '../widgets/chat_prompt_card.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_top_bar.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final ChatService _service = const ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _responseTimer;

  late final List<ChatMessage> _messages = _service.initialMessages();
  late final List<ChatPrompt> _prompts = _service.quickPrompts();

  bool _isTyping = false;

  @override
  void dispose() {
    _responseTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTopOfList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _sendMessage([String? preset]) {
    final String text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _isTyping) {
      return;
    }

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: text,
          isUser: true,
          time: _service.currentTimeLabel(DateTime.now()),
        ),
      );
      _controller.clear();
      _isTyping = true;
    });
    _scrollToTopOfList();

    _responseTimer?.cancel();
    _responseTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: _service.buildResponse(text),
            isUser: false,
            time: _service.currentTimeLabel(DateTime.now()),
          ),
        );
        _isTyping = false;
      });
      _scrollToTopOfList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: ChatBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isWide = constraints.maxWidth >= 980;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 28 : 16,
                  vertical: 14,
                ),
                child: Column(
                  children: <Widget>[
                    ChatTopBar(colors: colors),
                    const SizedBox(height: 14),
                    Expanded(
                      child: isWide
                          ? Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 320,
                                  child: ChatSidebar(
                                    prompts: _prompts,
                                    onPromptSelected: _sendMessage,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ChatPanel(
                                    messages: _messages,
                                    controller: _controller,
                                    scrollController: _scrollController,
                                    isTyping: _isTyping,
                                    onSend: _sendMessage,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 146,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _prompts.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (BuildContext context, int index) {
                                      final ChatPrompt prompt = _prompts[index];
                                      return SizedBox(
                                        width: 190,
                                        child: ChatPromptCard(
                                          prompt: prompt,
                                          onTap: () => _sendMessage(prompt.samplePrompt),
                                          compact: true,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Expanded(
                                  child: ChatPanel(
                                    messages: _messages,
                                    controller: _controller,
                                    scrollController: _scrollController,
                                    isTyping: _isTyping,
                                    onSend: _sendMessage,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
