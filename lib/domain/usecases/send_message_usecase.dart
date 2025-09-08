import 'package:spotify/domain/repository/chat_repository.dart';

// import '../entities/chat_message.dart';
// import '../repositories/chat_repository.dart';

class SendMessageParams {
  final String prompt;
  SendMessageParams(this.prompt);
}

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  /// returns assistant reply as string. Throws on error.
  Future<String> call(SendMessageParams params) async {
    return repository.getReply(params.prompt);
  }
}
