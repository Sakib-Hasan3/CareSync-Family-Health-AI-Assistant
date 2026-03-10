import 'package:hive_flutter/hive_flutter.dart';

class FavoritesRepository {
  static const String _boxName = 'emergency_favorites';
  Box<String>? _box;

  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(_boxName);
    }
  }

  Future<void> addFavorite(String contactId) async {
    await init();
    if (!_box!.containsKey(contactId)) {
      await _box!.put(contactId, contactId);
    }
  }

  Future<void> removeFavorite(String contactId) async {
    await init();
    await _box!.delete(contactId);
  }

  bool isFavorite(String contactId) {
    if (_box == null || !_box!.isOpen) return false;
    return _box!.containsKey(contactId);
  }

  List<String> getAllFavorites() {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList();
  }

  Future<void> clear() async {
    await init();
    await _box!.clear();
  }
}
