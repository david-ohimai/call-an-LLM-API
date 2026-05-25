// main.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Loads environment variables from a .env file
Future<Map<String, String>> loadEnv() async {
  final envFile = File('.env');
  if (!await envFile.exists()) {
    throw Exception('.env file not found');
  }
  final lines = await envFile.readAsLines();
  final env = <String, String>{};
  for (final line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length == 2) {
      env[parts[0].trim()] = parts[1].trim();
    }
  }
  return env;
}

// Calls the OpenRouter API and returns the model's text response
Future<String> callLlmApi(String prompt) async {
  final env = await loadEnv();

  final apiKey =
      Platform.environment['OPENROUTER_API_KEY'] ?? env['OPENROUTER_API_KEY'];
  final modelName = Platform.environment['MODEL_NAME'] ?? env['MODEL_NAME'];
  final apiUrl = Platform.environment['API_URL'] ?? env['API_URL'];

  if (apiKey == null || modelName == null || apiUrl == null) {
    throw Exception(
      'OPENROUTER_API_KEY, MODEL_NAME, or API_URL not found in environment',
    );
  }

  final url = Uri.parse('$apiUrl/chat/completions');
  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'model': modelName,
    'messages': [
      {'role': 'user', 'content': prompt},
    ],
  });

  final response = await http.post(url, headers: headers, body: body);

  final contentType = response.headers['content-type'] ?? '';
  if (!contentType.contains('application/json')) {
    throw Exception(
      'Expected JSON but got $contentType. Body: ${response.body.substring(0, 200)}',
    );
  }

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception(
      'API request failed: ${response.statusCode} ${response.body}',
    );
  }
}

void main() async {
  print(
    'Type your prompt and press Enter. Type "exit" or leave blank to quit.',
  );

  // Main loop to read user input and generate responses
  while (true) {
    stdout.write('\nEnter prompt: ');
    final prompt = stdin.readLineSync();

    if (prompt == null ||
        prompt.trim().isEmpty ||
        prompt.trim().toLowerCase() == 'exit') {
      print('Goodbye!');
      break;
    }

    try {
      final response = await callLlmApi(prompt.trim());
      print('\nResponse:\n$response');
    } catch (e) {
      print('Error: $e');
      break;
    }
  }
}
