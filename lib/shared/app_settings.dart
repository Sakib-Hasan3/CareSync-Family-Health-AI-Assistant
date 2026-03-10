import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Global app settings — persisted via Hive (non-sensitive) and
/// FlutterSecureStorage (PIN hash).
class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._();
  factory AppSettings() => _instance;
  AppSettings._();

  static const _boxName = 'app_settings';
  static const _keyTheme = 'theme_mode';
  static const _keyFontScale = 'font_scale';
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _pinKey = 'caresync_pin';

  final _secure = const FlutterSecureStorage();

  late Box _box;

  ThemeMode _themeMode = ThemeMode.light;
  double _fontScale = 1.0;
  bool _pinEnabled = false;
  bool _onboardingDone = false;

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  bool get pinEnabled => _pinEnabled;
  bool get onboardingDone => _onboardingDone;

  // font scale label for UI
  String get fontScaleLabel {
    if (_fontScale <= 0.85) return 'Small';
    if (_fontScale <= 1.0) return 'Normal';
    if (_fontScale <= 1.15) return 'Large';
    return 'Extra Large';
  }

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final themeStr = _box.get(_keyTheme, defaultValue: 'light') as String;
    _themeMode = themeStr == 'dark'
        ? ThemeMode.dark
        : themeStr == 'system'
            ? ThemeMode.system
            : ThemeMode.light;
    _fontScale = (_box.get(_keyFontScale, defaultValue: 1.0) as num).toDouble();
    _pinEnabled = _box.get(_keyPinEnabled, defaultValue: false) as bool;
    _onboardingDone = _box.get(_keyOnboardingDone, defaultValue: false) as bool;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _box.put(
      _keyTheme,
      mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.system
              ? 'system'
              : 'light',
    );
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    await _box.put(_keyFontScale, scale);
    notifyListeners();
  }

  Future<void> setOnboardingDone() async {
    _onboardingDone = true;
    await _box.put(_keyOnboardingDone, true);
    notifyListeners();
  }

  // ── PIN management ────────────────────────────────────────────────────────

  Future<void> setupPin(String pin) async {
    await _secure.write(key: _pinKey, value: pin);
    _pinEnabled = true;
    await _box.put(_keyPinEnabled, true);
    notifyListeners();
  }

  Future<void> disablePin() async {
    await _secure.delete(key: _pinKey);
    _pinEnabled = false;
    await _box.put(_keyPinEnabled, false);
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secure.read(key: _pinKey);
    return stored != null && stored == pin;
  }

  Future<bool> hasPin() async {
    final stored = await _secure.read(key: _pinKey);
    return stored != null && stored.isNotEmpty;
  }
}
