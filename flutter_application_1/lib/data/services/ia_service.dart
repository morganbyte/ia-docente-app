import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = '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'; 

  Future<String> getOpenAIResponse(String prompt) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://tu-app.com', 
        'X-Title': 'FlutterChatBotDemo'
      },
      body: jsonEncode({
        "model": "openai/gpt-3.5-turbo", 
        "messages": [
          {"role": "user", "content": prompt}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
     return utf8.decode(data['choices'][0]['message']['content'].codeUnits);

    } else {
      throw Exception('Error en la API: ${response.body}');
    }
  }
}
