import 'package:chatbot/models/chat_model.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PhotoBox extends StatelessWidget {
  ChatModel chatModel;
  PhotoBox({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(children: [
          Image.file(
            chatModel.file!,
            fit: BoxFit.cover,
            semanticLabel: 'Image',
            width: 200,
          ),
          const SizedBox(height: 8),
          Text(chatModel.text),
        ]),
      ),
    );
  }
}
