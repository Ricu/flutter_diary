import 'dart:convert';
import 'package:http/http.dart' as http;

class LlmPrettifying {
  static const String _openAiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _openAiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''); // Load from environment variables

  static const List<String> _categories = [
    "Health & Symptoms",
    "Physical Activity",
    "Daily Activities & Social Interactions",
    "Reflections & Ideas",
    "Meals & Nutrition",
    "Mood Tracker",
    "Sleep Patterns",
    "Miscellaneous Notes"
  ];

  static const String _promptTemplate = """
You are a helpful assistant that improves diary entries. The diary entries are transcriptions of audio recordings.
Make the text more readable and e.g. by fixing the grammar, but maintain the original meaning and sentiment.
If you do not know or understand words, do not change them. If you are unsure about the meaning of a sentence, do not change it.
Group the content into the following categories: {categories}.
Output the text as markdown, denoting each category with a heading. If there is no content for a category, simply leave the section content empty.
Please improve this diary entry:
{transcription}
""";

  static Future<String> prettifySingleRecording(String text) async {
    final String prompt = _promptTemplate
        .replaceAll('{categories}', _categories.join(', '))
        .replaceAll('{transcription}', text);

    try {
      final response = await http.post(
        Uri.parse(_openAiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that improves diary entries. Please follow the user\'s instructions.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return decodedResponse['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to prettify text. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error prettifying text: $e');
    }
  }
}