import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> transcribeAudio(String filePath) async {
    final url = Uri.parse("https://api.openai.com/v1/audio/transcriptions");

    var request = http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath("file", filePath));
    const String openAiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    request.headers.addAll({
      "Authorization": "Bearer $openAiKey",
    });

    request.fields["model"] = "whisper-1";
    request.fields["language"] = "de";

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        String transcription = jsonResponse['text'];
        return transcription;
      } else {
        throw Exception("Failed to transcribe audio. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }