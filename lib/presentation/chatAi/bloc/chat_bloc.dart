import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:spotify/domain/entities/message.dart';
import 'package:spotify/domain/usecases/send_message_usecase.dart';
import 'package:uuid/uuid.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final Uuid _uuid = const Uuid();

  ChatBloc({required this.sendMessageUseCase}) : super(ChatState.initial()) {
    on<SendUserMessageEvent>(_onSendUserMessage);
    on<ClearChatEvent>(_onClearChat);
  }

  Future<void> _onSendUserMessage(
    SendUserMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: event.text,
      sender: Sender.user,
    );

    // Immediately add user's message for responsiveness
    final updated = List<ChatMessage>.from(state.messages)..add(userMsg);
    emit(state.copyWith(messages: updated, isTyping: true, error: null));

    try {
      // Call the usecase
      final reply = await sendMessageUseCase(SendMessageParams(event.text));

      final assistantMsg = ChatMessage(
        id: _uuid.v4(),
        text: reply,
        sender: Sender.assistant,
      );

      final newList = List<ChatMessage>.from(state.messages)..add(assistantMsg);
      emit(state.copyWith(messages: newList, isTyping: false));
    } catch (e) {
      // error handling: show error on state and stop typing
      emit(state.copyWith(isTyping: false, error: e.toString()));
    }
  }

  void _onClearChat(ClearChatEvent event, Emitter<ChatState> emit) {
    emit(ChatState.initial());
  }

  @override
  Future<void> close() {
    // Nothing to dispose here beyond super
    return super.close();
  }
}
