// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class Butt extends StatelessWidget {
  String? text;
  void Function() onpressed;
  Butt({super.key, required this.onpressed, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 61, 132, 255),
          borderRadius: BorderRadius.circular(30)),
      child: TextButton(
        onPressed: onpressed,
        child: Text(
          text!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class Textfield extends StatelessWidget {
  String? text;
  TextEditingController? controller;
  Textfield({super.key, this.controller, this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: text,
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class MessageField extends StatelessWidget {
  String? text;
  TextEditingController? controller;
  void Function() buttonFunction;
  MessageField(
      {super.key, this.controller, this.text, required this.buttonFunction});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).brightness == Brightness.dark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: scheme.onSurface),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          IconButton(
            onPressed: buttonFunction,
            icon: Icon(
              Icons.file_copy,
              size: 20,
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
          )
        ],
      ),
    );
  }
}
