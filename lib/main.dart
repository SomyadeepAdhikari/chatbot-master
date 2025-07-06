import 'package:chatbot/bloc/bloc.dart';
import 'package:chatbot/pages/splash_screen.dart';
import 'package:chatbot/system/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/adapters.dart';

// ignore: constant_identifier_names
const APIKEY = 'AIzaSyB08UcJSf1AyqbaJC4WxNKOAPl0tGPgDwY';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(boxName);
  await Hive.openBox(userData);
  Gemini.init(apiKey: APIKEY);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MessageBloc(),
        child: const MaterialApp(
            debugShowCheckedModeBanner: false, home: SplashScreen()));
  }
}
