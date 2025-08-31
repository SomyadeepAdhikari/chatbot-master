import 'package:chatbot/bloc/bloc.dart';
import 'package:chatbot/pages/splash_screen.dart';
import 'package:chatbot/system/auth.dart';
import 'package:chatbot/theme/app_theme.dart';
import 'package:chatbot/services/settings_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:chatbot/theme/theme_cubit.dart';

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
  // Load custom API key if saved, else fall back to default
  final savedKey = SettingsService.apiKey;
  Gemini.init(apiKey: (savedKey != null && savedKey.isNotEmpty) ? savedKey : apiKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => MessageBloc()),
            BlocProvider(create: (_) => ThemeCubit()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              // Get text scale from settings service
              final textScale = SettingsService.textScale;
              
              return MaterialApp(
                title: 'Gemini Chat',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme.copyWith(
                  colorScheme: lightColorScheme ?? AppTheme.lightTheme.colorScheme,
                  textTheme: AppTheme.lightTheme.textTheme.apply(fontSizeFactor: textScale),
                ),
                darkTheme: AppTheme.darkTheme.copyWith(
                  colorScheme: darkColorScheme ?? AppTheme.darkTheme.colorScheme,
                  textTheme: AppTheme.darkTheme.textTheme.apply(fontSizeFactor: textScale),
                ),
                themeMode: themeState.mode,
                home: const SplashScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
