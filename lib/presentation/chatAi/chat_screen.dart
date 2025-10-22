import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/presentation/chatAi/bloc/chat_bloc.dart';
import 'package:spotify/presentation/chatAi/bloc/chat_event.dart';
import 'package:spotify/presentation/chatAi/bloc/chat_state.dart';
import 'package:spotify/presentation/chatAi/chat_bubble.dart';
import 'package:spotify/presentation/chatAi/typing_indicator.dart';
import 'package:spotify/presentation/home/pages/homescreen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          context.isDarkMode ? Color(0xff0D0C0C) : Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AI Assistant 🤖',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor:
            context.isDarkMode
                ? Colors.black.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: context.isDarkMode ? Colors.white : Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                List messages = [];
                bool isLoading = false;

                if (state is ChatLoaded) messages = state.messages;
                if (state is ChatLoading) isLoading = true;

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToEnd(),
                );

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          context.isDarkMode
                              ? [Color(0xff0D0C0C), Color(0xff0D0C0C)]
                              : [Colors.white, Colors.blue.shade50],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isLoading && index == messages.length) {
                        return const TypingIndicator();
                      }
                      return ChatBubble(message: messages[index]);
                    },
                  ),
                );
              },
            ),
          ),

          // Message Input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    context.isDarkMode
                        ? Color(0xff0D0C0C)
                        : Colors.blue.shade50,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Text Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.08),
                            Colors.purpleAccent.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: Colors.blueAccent,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 18,
                          ),
                          hintText: "Message...",
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade900.withOpacity(0.8)
                                  : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  //  Send Button
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.isNotEmpty) {
                        context.read<ChatBloc>().add(
                          SendMessageEvent(_controller.text),
                        );
                        _controller.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors:
                              context.isDarkMode
                                  ? [Color(0xff42C83C), Color(0xff42C83C)]
                                  : [Colors.lightBlue, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
