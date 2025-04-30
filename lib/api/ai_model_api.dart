import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiModelApi {
  Future<dynamic> getAIResponse(String prompt) async {
    final String? aiModelKey = dotenv.env['AI_MODEL_KEY'];
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $aiModelKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-r1:free",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "stream": false // set to true if you're handling streams
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      dynamic chatBotResponse = data['choices'][0]['message']['content'];
      print("AI RESPONSE $chatBotResponse");
      return chatBotResponse;
    } else {
      throw Exception('Failed to fetch AI response: ${response.body}');
    }
  }
}
