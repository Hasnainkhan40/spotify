import 'package:equatable/equatable.dart';
import 'package:spotify/domain/entities/message.dart';

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;

  const ChatState({required this.messages, required this.isTyping, this.error});

  factory ChatState.initial() => ChatState(messages: [], isTyping: false);

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping, error];
}
