import '../entities/message.dart';
import '../repository/chat_repository.dart';

class SendMessageParams {
  final String prompt;
  SendMessageParams(this.prompt);
}

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<Message> call(SendMessageParams params) async {
    return repository.getReply(params.prompt);
  }
}
