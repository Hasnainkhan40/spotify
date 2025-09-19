import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> generateText(String prompt) async {
  final url = Uri.parse(
    'https://api-inference.huggingface.co/models/distilgpt2',
  );

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer ${dotenv.env['HF_API_KEY']}',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'inputs': prompt,
      'parameters': {'max_new_tokens': 50},
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Hugging Face returns a list of generated texts
    if (data is List && data.isNotEmpty && data[0]['generated_text'] != null) {
      return data[0]['generated_text'];
    } else {
      return 'No text generated';
    }
  } else {
    return 'Error ${response.statusCode}: ${response.body}';
  }
}

void sendMessage() async {
  String prompt = "Hello, I am testing from Flutter!";
  String result = await generateText(prompt);
  print(result);
}
