import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  Locale _locale = const Locale('en'); // Default locale to 'en'

  LocaleProvider(Locale initialLocale) {
    _initializePreferences();
  }

  Locale get locale => _locale;

  // Initialize the locale from SharedPreferences or set default
  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? lang = _prefs?.getString('lang');

    if (lang != null && lang.isNotEmpty) {
      _locale = Locale(lang);
    } else {
      _locale = const Locale('en'); // Fallback to default (English)
    }

    notifyListeners();
  }

  // Set a new locale and save it to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    await _prefs?.setString('lang', locale.languageCode);

    notifyListeners();
  }

  // Clear the locale and revert to default ('en')
  Future<void> clearLocale() async {
    _locale = const Locale('en'); // Fallback to default (English)
    await _prefs?.remove('lang');
    notifyListeners();
  }
}
