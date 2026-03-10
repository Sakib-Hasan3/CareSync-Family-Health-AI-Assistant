import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the current app locale and persists it via FlutterSecureStorage.
class LanguageService {
  static final instance = LanguageService._();
  LanguageService._();

  final _storage = const FlutterSecureStorage();
  static const _key = 'app_lang_code';

  final locale = ValueNotifier<Locale>(const Locale('en'));

  static const supportedLocales = [
    Locale('en'),
    Locale('bn'),
    Locale('hi'),
    Locale('ar'),
  ];

  static const languageNames = {
    'en': 'English',
    'bn': 'বাংলা',
    'hi': 'हिन्दी',
    'ar': 'العربية',
  };

  static const languageNatives = {
    'en': 'English',
    'bn': 'Bengali',
    'hi': 'Hindi',
    'ar': 'Arabic',
  };

  Future<void> init() async {
    final code = await _storage.read(key: _key) ?? 'en';
    locale.value = Locale(code);
  }

  Future<void> setLocale(Locale l) async {
    locale.value = l;
    await _storage.write(key: _key, value: l.languageCode);
  }
}
