/// Local storage service for managing app data persistence
abstract class LocalStorageService {
  Future<void> initialize();
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> saveDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<void> saveStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);
  Future<void> saveObject(String key, Map<String, dynamic> object);
  Future<Map<String, dynamic>?> getObject(String key);
  Future<void> saveObjectList(String key, List<Map<String, dynamic>> objects);
  Future<List<Map<String, dynamic>>?> getObjectList(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}

/// Implementation using SharedPreferences (or Hive in production)
class LocalStorageServiceImpl implements LocalStorageService {
  // In a real implementation, this would use SharedPreferences or Hive
  final Map<String, dynamic> _storage = {};
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception(
        'LocalStorageService not initialized. Call initialize() first.',
      );
    }
  }

  @override
  Future<void> saveString(String key, String value) async {
    _ensureInitialized();
    _storage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    _ensureInitialized();
    return _storage[key] as String?;
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    _ensureInitialized();
    _storage[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    _ensureInitialized();
    return _storage[key] as bool?;
  }

  @override
  Future<void> saveInt(String key, int value) async {
    _ensureInitialized();
    _storage[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    _ensureInitialized();
    return _storage[key] as int?;
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    _ensureInitialized();
    _storage[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async {
    _ensureInitialized();
    return _storage[key] as double?;
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    _ensureInitialized();
    _storage[key] = List<String>.from(value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    _ensureInitialized();
    final value = _storage[key];
    return value != null ? List<String>.from(value) : null;
  }

  @override
  Future<void> remove(String key) async {
    _ensureInitialized();
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _ensureInitialized();
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    _ensureInitialized();
    return _storage.containsKey(key);
  }

  /// Save complex object as JSON string
  Future<void> saveObject(String key, Map<String, dynamic> object) async {
    _ensureInitialized();
    _storage[key] = object;
  }

  /// Get complex object from JSON string
  Future<Map<String, dynamic>?> getObject(String key) async {
    _ensureInitialized();
    final value = _storage[key];
    return value is Map<String, dynamic> ? value : null;
  }

  /// Save list of objects
  Future<void> saveObjectList(
    String key,
    List<Map<String, dynamic>> objects,
  ) async {
    _ensureInitialized();
    _storage[key] = objects;
  }

  /// Get list of objects
  Future<List<Map<String, dynamic>>?> getObjectList(String key) async {
    _ensureInitialized();
    final value = _storage[key];
    if (value is List) {
      return value.cast<Map<String, dynamic>>();
    }
    return null;
  }

  /// Get all keys
  Future<List<String>> getAllKeys() async {
    _ensureInitialized();
    return _storage.keys.toList();
  }

  /// Get storage size (approximate)
  Future<int> getStorageSize() async {
    _ensureInitialized();
    return _storage.length;
  }
}
