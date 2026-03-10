import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Stores a color code (as ARGB int) per family member ID.
/// Uses a plain Hive box — no adapter generation needed.
class FamilyColorRepository {
  static const _boxName = 'family_colors';

  static final FamilyColorRepository _instance = FamilyColorRepository._();
  factory FamilyColorRepository() => _instance;
  FamilyColorRepository._();

  late Box<int> _box;

  /// 10 pleasant palette options for color-coding family members.
  static const palette = [
    Color(0xFF2563EB), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Amber
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFF3B82F6), // Light blue
    Color(0xFFF97316), // Orange
  ];

  Future<void> init() async {
    _box = await Hive.openBox<int>(_boxName);
  }

  Color getColor(String memberId) {
    final val = _box.get(memberId);
    if (val != null) return Color(val);
    // Default: assign based on hash
    return palette[memberId.hashCode.abs() % palette.length];
  }

  Future<void> setColor(String memberId, Color color) async {
    await _box.put(memberId, color.value);
  }

  Color? getStoredColor(String memberId) {
    final val = _box.get(memberId);
    return val != null ? Color(val) : null;
  }
}
