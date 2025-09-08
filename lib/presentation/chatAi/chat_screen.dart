import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/entities/message.dart';
import 'package:spotify/presentation/chatAi/bloc/chat_bloc.dart';
import 'package:spotify/presentation/chatAi/bloc/chat_event.dart';
import 'package:spotify/presentation/chatAi/bloc/chat_state.dart';
// import '../../domain/entities/chat_message.dart';
// import '../bloc/chat_bloc.dart';
// import '../bloc/chat_event.dart';
// import '../bloc/chat_state.dart';
// import 'package:intl/intl.dart';
import 'package:intl/intl.dart'; // ✅ add this

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _chatBloc.add(SendUserMessageEvent(text));
    _controller.clear();
    // scroll to bottom a bit after layout
    Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.sender == Sender.user;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = Radius.circular(14);
    final bg =
        isUser
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).cardColor;
    final txtColor =
        isUser
            ? Colors.white
            : Theme.of(context).textTheme.bodyLarge?.color; // ✅ new

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
                bottomLeft: isUser ? radius : Radius.circular(4),
                bottomRight: isUser ? Radius.circular(4) : radius,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              msg.text,
              style: TextStyle(color: txtColor, height: 1.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat.Hm().format(msg.timestamp),
            style: Theme.of(context).textTheme.bodySmall, // ✅ new
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state.isTyping) _scrollToBottom();
                  if (state.error != null) {
                    final snack = SnackBar(
                      content: Text('Error: ${state.error}'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snack);
                  }
                },
                builder: (context, state) {
                  final messages = state.messages;
                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 12, bottom: 100),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final msg = messages[i];
                          return AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: Align(
                              alignment:
                                  msg.sender == Sender.user
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: _buildBubble(msg),
                            ),
                          );
                        },
                      ),
                      // typing indicator
                      if (state.isTyping)
                        Positioned(
                          left: 16,
                          bottom: 86,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 6,
                                      height: 6,
                                      child: _AnimatedDot(),
                                    ),
                                    SizedBox(width: 6),
                                    // simple textual indicator
                                    Text('Assistant is typing...'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: theme.scaffoldBackgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 140),
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Send a message...',
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // modern send button
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// tiny bouncing dot used as typing indicator
class _AnimatedDot extends StatefulWidget {
  const _AnimatedDot();

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    _a = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: const Icon(Icons.brightness_1, size: 8),
    );
  }
}
