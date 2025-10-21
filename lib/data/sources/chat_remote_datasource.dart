import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify/domain/entities/message.dart';
import '../models/message_model.dart';
import 'package:uuid/uuid.dart';

class ChatRemoteDataSource {
  final String apiKey;

  ChatRemoteDataSource(this.apiKey);

  Future<MessageModel> sendMessage(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": text},
            ],
          },
        ],
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final botText =
          data['candidates']?[0]['content']?['parts']?[0]['text']?.trim() ??
          'I am having trouble responding.';

      return MessageModel(
        id: const Uuid().v4(),
        text: botText,
        sender: Sender.bot,
        timestamp: DateTime.now(),
      );
    } else {
      throw Exception('Failed to get bot response: ${response.body}');
    }
  }
}
