import '../entities/message.dart';

abstract class ChatRepository {
  Future<Message> getReply(String prompt); // must match use case
}
