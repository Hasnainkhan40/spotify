abstract class ChatRepository {
  /// Send user prompt and return assistant reply.
  Future<String> getReply(String prompt);
}
