import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyLocale = 'app_locale';

class AppLocale extends ChangeNotifier {
  AppLocale();

  Locale _locale = const Locale('uz');
  Locale get locale => _locale;

  bool get isUz => _locale.languageCode == 'uz';
  bool get isRu => _locale.languageCode == 'ru';

  Future<void> ensureLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocale);
    if (code != null && (code == 'uz' || code == 'ru')) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
    notifyListeners();
  }

  Future<void> setUz() => setLocale(const Locale('uz'));
  Future<void> setRu() => setLocale(const Locale('ru'));
}
