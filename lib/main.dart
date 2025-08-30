import 'package:chatbot/bloc/bloc.dart';
import 'package:chatbot/pages/splash_screen.dart';
import 'package:chatbot/system/auth.dart';
import 'package:chatbot/theme/app_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/adapters.dart';

const apiKey = 'AIzaSyC99kfmGChH62Q9Agkt0iXPKcdB_vZNqf8'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for modern look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();
  await Hive.openBox(boxName);
  await Hive.openBox(userData);
  Gemini.init(apiKey: apiKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return BlocProvider(
          create: (context) => MessageBloc(),
          child: MaterialApp(
            title: 'Gemini Chat',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme.copyWith(
              colorScheme: lightColorScheme ?? AppTheme.lightTheme.colorScheme,
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              colorScheme: darkColorScheme ?? AppTheme.darkTheme.colorScheme,
            ),
            themeMode: ThemeMode.system,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
