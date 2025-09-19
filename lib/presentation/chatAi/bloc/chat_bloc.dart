import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/entities/message.dart';
import 'package:spotify/domain/usecases/send_message_usecase.dart';
// import '../../domain/entities/message.dart';
// import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:uuid/uuid.dart';

// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final SendMessageUseCase sendMessageUseCase;
//   final List<Message> _messages = [];

//   ChatBloc({required this.sendMessageUseCase}) : super(ChatInitial()) {
//     on<SendMessageEvent>((event, emit) async {
//       // Add user message
//       final userMessage = Message(
//         id: const Uuid().v4(),
//         text: event.text,
//         sender: Sender.user,
//         timestamp: DateTime.now(),
//       );
//       _messages.add(userMessage);
//       emit(ChatLoaded(List.from(_messages)));

//       // Emit loading
//       //      emit(ChatLoading());

//       try {
//         // Wrap the text in SendMessageParams
//         final botMessage = await sendMessageUseCase(
//           SendMessageParams(event.text),
//         );

//         // Add bot message to list
//         _messages.add(botMessage);
//         emit(ChatLoaded(List.from(_messages)));
//       } catch (e) {
//         emit(ChatError(e.toString()));
//       }
//     });
//   }
// }

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final List<Message> _messages = [];

  ChatBloc({required this.sendMessageUseCase}) : super(ChatInitial()) {
    on<SendMessageEvent>((event, emit) async {
      // 1️⃣ Add user message
      final userMessage = Message(
        id: const Uuid().v4(),
        text: event.text,
        sender: Sender.user,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      emit(ChatLoaded(List.from(_messages)));

      // 2️⃣ Add temporary "Bot is typing..." message
      final typingMessage = Message(
        id: const Uuid().v4(),
        text: "Bot is typing...",
        sender: Sender.bot,
        timestamp: DateTime.now(),
      );
      _messages.add(typingMessage);
      emit(ChatLoaded(List.from(_messages)));

      try {
        // 3️⃣ Calculate dynamic delay based on user message length
        int delayMs = (event.text.length * 100 ~/ 10); // 10 chars per 100ms
        if (delayMs < 500) delayMs = 500; // minimum 0.5s
        if (delayMs > 2500) delayMs = 2500; // maximum 2.5s
        await Future.delayed(Duration(milliseconds: delayMs));

        // 4️⃣ Call Gemini API
        final botMessage = await sendMessageUseCase(
          SendMessageParams(event.text),
        );

        // 5️⃣ Remove the typing message
        _messages.removeWhere((msg) => msg.text == "Bot is typing...");

        // 6️⃣ Add actual bot reply
        _messages.add(botMessage);
        emit(ChatLoaded(List.from(_messages)));
      } catch (e) {
        // Remove typing message if error occurs
        _messages.removeWhere((msg) => msg.text == "Bot is typing...");
        emit(ChatError(e.toString()));
      }
    });
  }
}
