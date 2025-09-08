import 'dart:convert';
import 'package:http/http.dart' as http;

// class HuggingFaceInferenceDataSource {
//   final String apiKey;
//   final http.Client client;

//   HuggingFaceInferenceDataSource({required this.apiKey, required this.client});

//   /// Calls a text generation model hosted on HF.
//   /// modelId example: "gpt2" or "google/flan-t5-small" or another text-gen model on HF Hub.
//   Future<String> generateText({
//     required String modelId,
//     required String prompt,
//     int maxTokens = 256,
//   }) async {
//     final url = Uri.parse(
//       'https://api-inference.huggingface.co/models/$modelId',
//     );

//     final resp = await client.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $apiKey',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         "inputs": prompt,
//         "parameters": {"max_new_tokens": maxTokens, "temperature": 0.7},
//       }),
//     );

//     if (resp.statusCode == 200) {
//       final body = jsonDecode(resp.body);
//       // The serverless inference usually responds with either {"generated_text": "..."}
//       // or an array for some models. We attempt to extract text robustly.
//       if (body is Map && body.containsKey('generated_text')) {
//         return body['generated_text'] as String;
//       } else if (body is List && body.isNotEmpty) {
//         final first = body.first;
//         if (first is Map && first.containsKey('generated_text')) {
//           return first['generated_text'] as String;
//         } else if (first is String) {
//           return first;
//         }
//       } else if (body is String) {
//         return body;
//       }

//       // fallback to raw body
//       return resp.body;
//     } else {
//       // HF returns 503 / 429 for rate limits or cold starts; bubble message up
//       throw HuggingFaceException(
//         'HF API error: ${resp.statusCode} ${resp.body}',
//       );
//     }
//   }
// }

// class HuggingFaceException implements Exception {
//   final String message;
//   HuggingFaceException(this.message);
//   @override
//   String toString() => 'HuggingFaceException: $message';
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

class HuggingFaceInferenceDataSource {
  final String apiKey;
  final http.Client client;

  HuggingFaceInferenceDataSource({required this.apiKey, required this.client});

  Future<String> generateText({
    required String modelId,
    required String prompt,
    int maxTokens = 128,
  }) async {
    final url = Uri.parse(
      "https://api-inference.huggingface.co/models/$modelId",
    );

    final response = await client.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {"max_new_tokens": maxTokens},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // gpt2 and text models return a list of generated_text
      if (data is List &&
          data.isNotEmpty &&
          data[0]["generated_text"] != null) {
        return data[0]["generated_text"];
      }

      throw Exception("Unexpected response format: ${response.body}");
    } else {
      throw Exception(
        "Failed to generate text: ${response.statusCode} ${response.body}",
      );
    }
  }
}
