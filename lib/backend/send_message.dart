import 'dart:convert';
import 'dart:developer';
import 'package:chatbot/main.dart';
import 'package:chatbot/models/user_model.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;
import 'package:chatbot/models/chat_model.dart';

// Primary implementation with fallback support
Future<ChatModel> getdata(ChatModel message, User geminiUser) async {
  try {
    log('Attempting to send message to Gemini: ${message.text}');
    
    // First try the flutter_gemini package
    final gemini = Gemini.instance;
    final response = await gemini.text(message.text);
    
    if (response != null && response.content != null && response.content!.parts != null) {
      final responseText = response.content!.parts!.first.text ?? 'No response received';
      log('Gemini response received successfully');
      
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: responseText,
        isSender: false,
      );
    } else {
      log('Empty response from Gemini, trying HTTP fallback');
      return await getdataHttp(message, geminiUser);
    }
  } catch (e) {
    log('Flutter Gemini failed: $e');
    
    // Check for specific error types
    if (e.toString().contains('404') || e.toString().contains('validateStatus')) {
      log('API endpoint issue detected, trying HTTP fallback');
      return await getdataHttp(message, geminiUser);
    } else if (e.toString().contains('API key') || e.toString().contains('INVALID_ARGUMENT')) {
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: '🔑 Invalid API Key detected!\n\nTo fix this:\n1. Go to https://aistudio.google.com/app/apikey\n2. Create a new API key\n3. Replace the API key in lib/main.dart\n4. Restart the app\n\nCurrent error: ${e.toString()}',
        isSender: false,
      );
    } else {
      log('Trying HTTP fallback due to error: $e');
      return await getdataHttp(message, geminiUser);
    }
  }
}

// Enhanced HTTP implementation with better error handling
Future<ChatModel> getdataHttp(ChatModel message, User geminiUser) async {
  try {
    const headers = {'Content-Type': 'application/json'};
    const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

    var body = {
      "contents": [
        {
          "parts": [
            {"text": message.text}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 1,
        "topP": 1,
        "maxOutputTokens": 2048,
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH", 
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    };

    log('Making HTTP request to Gemini API');
    log('Request URL: $url');
    
    final response = await http.post(
      Uri.parse(url), 
      headers: headers, 
      body: jsonEncode(body)
    );

    log('HTTP Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      log('Successful response received');
      
      if (result["candidates"] != null && 
          result["candidates"].isNotEmpty &&
          result["candidates"][0]['content'] != null &&
          result["candidates"][0]['content']['parts'] != null &&
          result["candidates"][0]['content']['parts'].isNotEmpty) {
        
        var output = result["candidates"][0]['content']['parts'][0]['text'];
        
        return ChatModel(
          user: geminiUser,
          createAt: DateTime.now(),
          text: output,
          isSender: false,
        );
      } else {
        return ChatModel(
          user: geminiUser,
          createAt: DateTime.now(),
          text: 'I received an unexpected response format. Please try again.',
          isSender: false,
        );
      }
    } else if (response.statusCode == 400) {
      log('API Error 400: ${response.body}');
      final errorBody = jsonDecode(response.body);
      if (errorBody['error'] != null && 
          errorBody['error']['message'] != null &&
          errorBody['error']['message'].toString().contains('API key')) {
        return ChatModel(
          user: geminiUser,
          createAt: DateTime.now(),
          text: '🔑 Invalid API Key!\n\nTo fix this:\n1. Go to https://aistudio.google.com/app/apikey\n2. Create a new API key\n3. Replace the API key in lib/main.dart\n4. Restart the app\n\nError: ${errorBody['error']['message']}',
          isSender: false,
        );
      }
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: 'API Error (400): ${errorBody['error']?['message'] ?? response.body}',
        isSender: false,
      );
    } else if (response.statusCode == 404) {
      log('API Error 404: ${response.body}');
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: '🚫 API Endpoint Not Found (404)\n\nThis might be due to:\n1. Invalid API key\n2. Incorrect API endpoint\n3. Service temporarily unavailable\n\nPlease:\n1. Check your API key at https://aistudio.google.com/app/apikey\n2. Ensure the API key has proper permissions\n3. Try again later if the service is down',
        isSender: false,
      );
    } else {
      log('API Error ${response.statusCode}: ${response.body}');
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: 'API Error (${response.statusCode}): ${response.body}',
        isSender: false,
      );
    }
  } catch (e) {
    log('HTTP API Error: $e');
    return ChatModel(
      user: geminiUser,
      createAt: DateTime.now(),
      text: 'Network error: ${e.toString()}. Please check your internet connection and API key.',
      isSender: false,
    );
  }
}

Future<ChatModel> sendImageData(ChatModel message, User geminiUser) async {
  try {
    log('Attempting to send image with text to Gemini: ${message.text}');
    
    if (message.file == null) {
      return ChatModel(
        text: 'No image file provided',
        user: geminiUser,
        createAt: DateTime.now(),
        isSender: false,
      );
    }

    // First try flutter_gemini
    final gemini = Gemini.instance;
    final response = await gemini.textAndImage(
      text: message.text.isEmpty ? "What do you see in this image?" : message.text,
      images: [message.file!.readAsBytesSync()]
    );

    if (response != null && response.content != null && response.content!.parts != null) {
      final responseText = response.content!.parts!.first.text ?? 'No response received for image';
      log('Gemini image response received successfully');
      
      return ChatModel(
        text: responseText,
        user: geminiUser,
        createAt: DateTime.now(),
        isSender: false,
      );
    } else {
      log('Empty response from Gemini for image');
      return ChatModel(
        text: 'I could not analyze the image. Please try again.',
        user: geminiUser,
        createAt: DateTime.now(),
        isSender: false,
      );
    }
  } catch (e) {
    log('Error processing image with Gemini: $e');
    
    // Handle specific error types
    if (e.toString().contains('404') || e.toString().contains('validateStatus')) {
      return ChatModel(
        text: '🚫 Image API Error (404)\n\nThis might be due to:\n1. Invalid API key\n2. Image processing service unavailable\n3. Incorrect API endpoint\n\nPlease check your API key at https://aistudio.google.com/app/apikey',
        user: geminiUser,
        createAt: DateTime.now(),
        isSender: false,
      );
    } else if (e.toString().contains('API key') || e.toString().contains('INVALID_ARGUMENT')) {
      return ChatModel(
        text: '🔑 Invalid API Key for Image Processing!\n\nTo fix this:\n1. Go to https://aistudio.google.com/app/apikey\n2. Create a new API key\n3. Replace the API key in lib/main.dart\n4. Restart the app',
        user: geminiUser,
        createAt: DateTime.now(),
        isSender: false,
      );
    } else {
      return ChatModel(
        text: 'Error processing image: ${e.toString()}. Please try again with a different image or check your API key.',
        user: geminiUser,
        createAt: DateTime.now(),
        isSender: false,
      );
    }
  }
}
