import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app language preferences
class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'English';
  
  static String _currentLanguage = _defaultLanguage;

  /// Initialize and load saved language preference
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  /// Get current selected language
  static String get currentLanguage => _currentLanguage;

  /// Set language and save to preferences
  static Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  /// Get language code (for API calls)
  static String getLanguageCode() {
    const codes = {
      'English': 'en',
      'Hindi': 'hi',
      'Punjabi': 'pa',
      'Haryanvi': 'brx',
    };
    return codes[_currentLanguage] ?? 'en';
  }
}
