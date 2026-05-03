import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/chat_prompt.dart';
import '../services/chat_service.dart';
import '../services/firebase_service.dart';
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
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _responseTimer;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  List<ChatMessage> _messages = <ChatMessage>[];
  late final List<ChatPrompt> _prompts = _service.quickPrompts();

  bool _isTyping = false;
  bool _isLoading = true;
  String? _userId;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseChat();
  }

  @override
  void dispose() {
    _responseTimer?.cancel();
    _messagesSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeFirebaseChat() async {
    try {
      final user = _firebaseService.getCurrentUser();
      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      _userId = user.uid;

      final DocumentSnapshot? latestConversation =
          await _firebaseService.getLatestConversation(user.uid);

      if (latestConversation == null) {
        _conversationId = await _firebaseService.createConversation(
          userId: user.uid,
          title: 'Nova AI Chat',
        );
        await _seedInitialMessages();
      } else {
        _conversationId = latestConversation.id;
      }

      await _subscribeToMessages();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _seedInitialMessages() async {
    final String? userId = _userId;
    final String? conversationId = _conversationId;
    if (userId == null || conversationId == null) {
      return;
    }

    final List<ChatMessage> initialMessages = _service.initialMessages();
    for (final ChatMessage message in initialMessages.reversed) {
      await _firebaseService.saveChatMessage(
        userId: userId,
        conversationId: conversationId,
        text: message.text,
        isUser: message.isUser,
        timestamp: message.time,
      );
    }
  }

  Future<void> _subscribeToMessages() async {
    final String? userId = _userId;
    final String? conversationId = _conversationId;
    if (userId == null || conversationId == null) {
      return;
    }

    await _messagesSubscription?.cancel();
    _messagesSubscription = _firebaseService
        .getChatMessages(userId: userId, conversationId: conversationId)
        .listen((QuerySnapshot snapshot) {
      final List<ChatMessage> loadedMessages = snapshot.docs
          .map((QueryDocumentSnapshot doc) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return ChatMessage(
              text: (data['text'] as String?) ?? '',
              isUser: (data['isUser'] as bool?) ?? false,
              time: (data['timestamp'] as String?) ?? '',
            );
          })
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _messages = loadedMessages;
      });

      _scrollToTopOfList();
    });
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
    final String? userId = _userId;
    final String? conversationId = _conversationId;
    final String text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _isTyping || userId == null || conversationId == null) {
      return;
    }

    setState(() {
      _controller.clear();
      _isTyping = true;
    });
    _scrollToTopOfList();

    final String userTime = _service.currentTimeLabel(DateTime.now());
    _firebaseService.saveChatMessage(
      userId: userId,
      conversationId: conversationId,
      text: text,
      isUser: true,
      timestamp: userTime,
    );

    _responseTimer?.cancel();
    _responseTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) {
        return;
      }

      final String responseText = _service.buildResponse(text);
      setState(() {
        _isTyping = false;
      });

      _firebaseService.saveChatMessage(
        userId: userId,
        conversationId: conversationId,
        text: responseText,
        isUser: false,
        timestamp: _service.currentTimeLabel(DateTime.now()),
      );

      _scrollToTopOfList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: ChatBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _userId == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Sign in from the app home screen to access your chat history.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
              : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isWide = constraints.maxWidth >= 980;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 28 : 16,
                        vertical: 14,
                      ),
                      child: Column(
                        children: <Widget>[
                          ChatTopBar(
                            colors: colors,
                            onSignOut: _firebaseService.signOut,
                          ),
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
                                            separatorBuilder:
                                              (BuildContext context, int index) =>
                                                const SizedBox(width: 12),
                                          itemBuilder:
                                              (BuildContext context, int index) {
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
