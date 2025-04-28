import 'dart:convert';
import 'package:http/http.dart' as http;

class AiModelApi {
  Future<dynamic> getAIResponse(String prompt) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Bearer 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',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-r1-distill-llama-70b:free",
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
