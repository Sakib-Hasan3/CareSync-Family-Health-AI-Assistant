import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'models/medication.dart';

class MedicationRepository {
  static const String _boxName = 'medications_box';
  Box<Medication>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(200)) {
      Hive.registerAdapter(MedicationAdapter());
    }
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<Medication>(_boxName);
    } else {
      _box = await Hive.openBox<Medication>(_boxName);
    }

    // In debug mode, seed the box with a sample medication so the UI
    // shows data immediately for testing/demo purposes.
    if (kDebugMode && (_box?.isEmpty ?? true)) {
      final sample = Medication(
        id: 'sample-aspirin',
        name: 'Aspirin',
        dosage: '100 mg',
        frequency: 'Once daily',
        remaining: 10,
        time: '9:00 AM',
      );
      await addOrUpdate(sample);
    }
  }

  List<Medication> getAll() {
    return _box?.values.toList() ?? [];
  }

  Future<void> addOrUpdate(Medication m) async {
    await _box?.put(m.id, m);
  }

  Future<void> delete(String id) async {
    await _box?.delete(id);
  }

  Medication? getById(String id) {
    return _box?.get(id);
  }

  Future<void> close() async {
    await _box?.close();
  }
}
