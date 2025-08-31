import 'package:hive_flutter/adapters.dart';

class SettingsService {
  static const String _boxName = 'userData';
  
  static Box? get _box {
    try {
      return Hive.isBoxOpen(_boxName) ? Hive.box(_boxName) : null;
    } catch (e) {
      return null;
    }
  }
  
  // Text Scale
  static double get textScale => _box?.get('textScale', defaultValue: 1.0) ?? 1.0;
  static set textScale(double value) => _box?.put('textScale', value);
  
  // Show Timestamps
  static bool get showTimestamps => _box?.get('showTimestamps', defaultValue: true) ?? true;
  static set showTimestamps(bool value) => _box?.put('showTimestamps', value);
  
  // Temperature (AI Creativity)
  static double get temperature => _box?.get('temperature', defaultValue: 0.7) ?? 0.7;
  static set temperature(double value) => _box?.put('temperature', value);
  
  // Max Tokens
  static int get maxTokens => _box?.get('maxTokens', defaultValue: 2048) ?? 2048;
  static set maxTokens(int value) => _box?.put('maxTokens', value);
  
  // Selected Model
  static String get selectedModel => _box?.get('selectedModel', defaultValue: 'gemini-1.5-flash') ?? 'gemini-1.5-flash';
  static set selectedModel(String value) => _box?.put('selectedModel', value);
  
  // API Key
  static String? get apiKey => _box?.get('apiKey');
  static set apiKey(String? value) {
    if (_box != null) {
      if (value == null || value.isEmpty) {
        _box!.delete('apiKey');
      } else {
        _box!.put('apiKey', value);
      }
    }
  }
  
  // Clear all settings
  static Future<void> clearAllSettings() async {
    await _box?.clear();
  }
  
  // Export settings as map
  static Map<String, dynamic> exportSettings() {
    return {
      'textScale': textScale,
      'showTimestamps': showTimestamps,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'selectedModel': selectedModel,
    };
  }
}
