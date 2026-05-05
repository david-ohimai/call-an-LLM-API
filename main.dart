import 'dart:io';
import 'dart:convert';

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

// Generates text using the OpenRouter API
Future<String> generateText(String prompt) async {
  final env = await loadEnv();
  final apiKey = Platform.environment['OPENROUTER_API_KEY'] ?? env['OPENROUTER_API_KEY'];
  final modelName = Platform.environment['MODEL_NAME'] ?? env['MODEL_NAME'];
  final apiUrl = Platform.environment['API_URL'] ?? env['API_URL'];

  if (apiKey == null || modelName == null) {
    throw Exception('API key or model name not found in environment variables');
  }

  // Make the API request
  final client = HttpClient();
  final url = Uri.parse(apiUrl!);

  final request = await client.postUrl(url);
  request.headers.set('Authorization', 'Bearer $apiKey');
  request.headers.set('Content-Type', 'application/json');

  final body = jsonEncode({
    'model': modelName,
    'messages': [
      {'role': 'user', 'content': prompt}
    ],
  });

  request.write(body);
  final response = await request.close();

  if (response.statusCode == 200) {
    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody);
    return data['choices'][0]['message']['content'];
  } else {
    final responseBody = await response.transform(utf8.decoder).join();
    throw Exception('Failed to generate text: ${response.statusCode} $responseBody');
  }
}

void main() async {
  print('Type your prompt and press Enter. Type "exit" or leave blank to quit.');

  // Main loop to read user input and generate responses
  while (true) {
    stdout.write('\nEnter prompt: ');
    final prompt = stdin.readLineSync();

    if (prompt == null || prompt.trim().isEmpty || prompt.trim().toLowerCase() == 'exit') {
      print('Goodbye!');
      break;
    }

    try {
      final response = await generateText(prompt.trim());
      print('\nResponse:\n$response');
    } catch (e) {
      print('Error: $e');
      break;
    }
  }
}
