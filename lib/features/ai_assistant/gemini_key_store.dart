import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small helper to persist a Gemini API key securely on-device.
///
/// This avoids hardcoding the API key in source. The AI service checks for a
/// build-time `--dart-define=GEMINI_API_KEY=...` first, then any key stored
/// via this helper.
class GeminiKeyStore {
  static const String _storageKey = 'GEMINI_API_KEY';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveKey(String key) async {
    await _storage.write(key: _storageKey, value: key);
  }

  static Future<String?> getKey() async {
    return await _storage.read(key: _storageKey);
  }

  static Future<void> deleteKey() async {
    await _storage.delete(key: _storageKey);
  }

  static Future<bool> hasKey() async {
    final v = await getKey();
    return v != null && v.isNotEmpty;
  }
}
