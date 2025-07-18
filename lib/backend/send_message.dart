import 'dart:convert';
import 'dart:developer';
import 'package:chatbot/main.dart';
import 'package:chatbot/models/user_model.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;
import 'package:chatbot/models/chat_model.dart';

// Using flutter_gemini package for better reliability
Future<ChatModel> getdata(ChatModel message, User geminiUser) async {
  try {
    final gemini = Gemini.instance;
    
    log('Sending message to Gemini: ${message.text}');
    
    final response = await gemini.text(message.text);
    
    if (response != null && response.content != null && response.content!.parts != null) {
      final responseText = response.content!.parts!.first.text ?? 'No response received';
      
      log('Gemini response: $responseText');
      
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: responseText,
        isSender: false,
      );
    } else {
      log('Empty response from Gemini');
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: 'I apologize, but I received an empty response. Please try again.',
        isSender: false,
      );
    }
  } catch (e) {
    log('Error calling Gemini API: $e');
    
    // Check if it's an API key issue
    if (e.toString().contains('API key') || e.toString().contains('INVALID_ARGUMENT')) {
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: '🔑 Invalid API Key detected!\n\nTo fix this:\n1. Go to https://aistudio.google.com/app/apikey\n2. Create a new API key\n3. Replace the API key in lib/main.dart\n4. Restart the app',
        isSender: false,
      );
    }
    
    return ChatModel(
      user: geminiUser,
      createAt: DateTime.now(),
      text: 'I encountered an error: ${e.toString()}. Please check your internet connection and try again.',
      isSender: false,
    );
  }
}

// Backup HTTP implementation in case flutter_gemini fails
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
      ]
    };

    log('Making HTTP request to: $url');
    log('Request body: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse(url), 
      headers: headers, 
      body: jsonEncode(body)
    );

    log('HTTP Response status: ${response.statusCode}');
    log('HTTP Response body: ${response.body}');

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      
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
      // Handle API key errors specifically
      final errorBody = jsonDecode(response.body);
      if (errorBody['error'] != null && 
          errorBody['error']['message'] != null &&
          errorBody['error']['message'].toString().contains('API key')) {
        return ChatModel(
          user: geminiUser,
          createAt: DateTime.now(),
          text: '🔑 Invalid API Key!\n\nTo fix this:\n1. Go to https://aistudio.google.com/app/apikey\n2. Create a new API key\n3. Replace the API key in lib/main.dart\n4. Restart the app\n\nCurrent key appears to be invalid or expired.',
          isSender: false,
        );
      }
      return ChatModel(
        user: geminiUser,
        createAt: DateTime.now(),
        text: 'API Error (${response.statusCode}): ${response.body}',
        isSender: false,
      );
    } else {
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
      text: 'Network error: ${e.toString()}. Please check your internet connection.',
      isSender: false,
    );
  }
}

Future<ChatModel> sendImageData(ChatModel message, User geminiUser) async {
  try {
    final gemini = Gemini.instance;
    
    log('Sending image with text to Gemini: ${message.text}');
    
    if (message.file == null) {
      return ChatModel(
        text: 'No image file provided',
        user: geminiUser,
        createAt: DateTime.now(),
        isSender: false,
      );
    }

    final response = await gemini.textAndImage(
      text: message.text.isEmpty ? "What do you see in this image?" : message.text,
      images: [message.file!.readAsBytesSync()]
    );

    if (response != null && response.content != null && response.content!.parts != null) {
      final responseText = response.content!.parts!.first.text ?? 'No response received for image';
      
      log('Gemini image response: $responseText');
      
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
    return ChatModel(
      text: 'Error processing image: ${e.toString()}. Please try again.',
      user: geminiUser,
      createAt: DateTime.now(),
      isSender: false,
    );
  }
}
