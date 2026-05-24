# LLM CLI Chat (Dart)

A simple command-line app that sends prompts to an LLM via the OpenRouter API and prints responses.

---

## Requirements

- Dart SDK (https://dart.dev/get-dart)
- An OpenRouter API key (https://openrouter.ai)

---

## Setup

### 1. Clone or copy the project files

Your project should have this structure:

  my_project/
    main.dart
    pubspec.yaml
    .env

### 2. Add the http dependency

In pubspec.yaml, add:

  dependencies:
    http: ^1.2.0

Then run:

  dart pub get

### 3. Create a .env file

In the project root, create a file named .env with these three variables:

  OPENROUTER_API_KEY=your_openrouter_api_key_here
  MODEL_NAME=nvidia/nemotron-3-nano-30b-a3b:freeopenai/gpt-4o
  API_URL=https://openrouter.ai/api/v1/chat/completions

Replace the values with your actual API key and preferred model.
You can browse available models at https://openrouter.ai/models.

---

## Running the app

  dart run main.dart

You will see:

  Type your prompt and press Enter. Type "exit" or leave blank to quit.

  Enter prompt:

Type any prompt and press Enter. The app prints the model's response, then waits for your next prompt.

To quit, type exit or press Enter on a blank line.

---

## How it works

loadEnv() reads key-value pairs from .env into a map.

callLlmApi(prompt) reads the env map, builds a POST request to the OpenRouter API, and returns the model's text response.

main() runs a loop that reads prompts from stdin, calls callLlmApi, and prints responses until you exit.

---

## Troubleshooting

.env file not found: make sure .env is in the same directory you run dart run from.

API request failed 401: your OPENROUTER_API_KEY is missing or invalid.

API request failed 404: the MODEL_NAME you set does not exist on OpenRouter.

package not found: run dart pub get after editing pubspec.yaml.