import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppThemeMode { system, light, dark }

class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.system));

  void setSystem() => emit(const ThemeState(ThemeMode.system));
  void setLight() => emit(const ThemeState(ThemeMode.light));
  void setDark() => emit(const ThemeState(ThemeMode.dark));
}
