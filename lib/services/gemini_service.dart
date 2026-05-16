import 'dart:convert';
import 'package:http/http.dart' as http;

const String _geminiApiKey = 'AIzaSyA6NVW98F9YRcGXglYGYOLALOo0BWw7jmE';
const String _model = 'gemini-2.5-flash';

class GeminiService {
  Future<String> getGermanSpeakingFeedback(String transcript) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_geminiApiKey',
    );

    final prompt =
        'You are a friendly German tutor. The learner said: "$transcript". '
        'Reply briefly. Correct major mistakes, explain in simple English, '
        'and give one improved German version.';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Gemini ${response.statusCode}: ${response.body}');
    }
  }
}
