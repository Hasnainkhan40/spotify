import 'package:spotify/data/sources/hf_BaEvaSDwpbfTziykKpDWDjepfhORiBzrHSinference_datasource.dart';
import 'package:spotify/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final HuggingFaceInferenceDataSource dataSource;
  final String modelId;

  ChatRepositoryImpl({
    required this.dataSource,
    this.modelId = 'gpt2', // default lightweight model - replace as needed
  });

  @override
  Future<String> getReply(String prompt) async {
    try {
      final reply = await dataSource.generateText(
        modelId: modelId,
        prompt: prompt,
        maxTokens: 256,
      );

      // Optional: basic cleanup
      return reply.trim();
    } catch (e) {
      rethrow;
    }
  }
}
