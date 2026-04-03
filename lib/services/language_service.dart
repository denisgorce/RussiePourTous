import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { fr, ru }

class LanguageService extends ChangeNotifier {
  static const String _prefKey = 'app_language';

  AppLanguage _currentLanguage = AppLanguage.fr;
  Map<String, String> _strings = {};
  bool _isLoaded = false;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isFrench => _currentLanguage == AppLanguage.fr;
  bool get isLoaded => _isLoaded;

  String get langCode => _currentLanguage == AppLanguage.fr ? 'fr' : 'ru';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved == 'ru') {
      _currentLanguage = AppLanguage.ru;
    }
    await _loadStrings();
  }

  Future<void> _loadStrings() async {
    try {
      final jsonString = await rootBundle.loadString('assets/lang/$langCode.json');
      final Map<String, dynamic> decoded = json.decode(jsonString);
      _strings = decoded.map((k, v) => MapEntry(k, v.toString()));
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('LanguageService: failed to load $langCode strings: $e');
    }
  }

  /// Translate a UI key
  String t(String key) => _strings[key] ?? key;

  /// Toggle between FR and RU instantly
  Future<void> toggle() async {
    _currentLanguage = isFrench ? AppLanguage.ru : AppLanguage.fr;
    await _loadStrings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, langCode);
    // notifyListeners() already called inside _loadStrings
  }

  /// Get content from a lesson JSON node based on current language
  dynamic fromLesson(Map<String, dynamic> lessonData, String key) {
    return lessonData[langCode]?[key];
  }

  /// Get a string safely from lesson data
  String lessonString(Map<String, dynamic> lessonData, String key) {
    final val = lessonData[langCode]?[key];
    return val?.toString() ?? '';
  }
}
