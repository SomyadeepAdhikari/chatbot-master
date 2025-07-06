import 'dart:io';

import 'package:chatbot/component/component.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ImagePage extends StatelessWidget {
  File file;
  TextEditingController controller;
  void Function() buttonFunction;
  ImagePage(
      {super.key,
      required this.file,
      required this.buttonFunction,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Center(
        child: Container(
          width: 300,
          height: 300,
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 50),
      Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                  child: Textfield(
                controller: controller,
              )),
              IconButton(
                  onPressed: buttonFunction, icon: const Icon(Icons.send))
            ],
          ),
        ),
      )
    ]);
  }
}
