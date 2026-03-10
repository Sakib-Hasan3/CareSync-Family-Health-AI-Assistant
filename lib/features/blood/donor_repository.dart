import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'models/donor.dart';

class DonorRepository {
  static const String boxName = 'blood_donors_box';
  Box<Donor>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(210)) Hive.registerAdapter(DonorAdapter());
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<Donor>(boxName);
    } else {
      _box = await Hive.openBox<Donor>(boxName);
    }

    if (kDebugMode && (_box?.isEmpty ?? true)) {
      final sample = Donor(
        id: 'donor-sample-1',
        name: 'Rahim Uddin',
        bloodGroup: 'O+',
        phone: '+8801710000000',
        city: 'Dhaka',
        available: true,
      );
      await addOrUpdate(sample);
    }
  }

  List<Donor> getAll() => _box?.values.toList() ?? [];

  Future<void> addOrUpdate(Donor d) async {
    if (_box == null) await init();
    await _box!.put(d.id, d);
  }

  Future<void> remove(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  Donor? getById(String id) => _box?.get(id);

  Future<void> close() async => await _box?.close();
}
