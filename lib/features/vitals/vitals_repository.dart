import 'package:hive/hive.dart';
import 'models/vital_record.dart';

class VitalsRepository {
  static const _boxName = 'vitals_box';
  static bool _initialized = false;
  static final _instance = VitalsRepository._();
  factory VitalsRepository() => _instance;
  VitalsRepository._();

  Future<void> init() async {
    if (_initialized) return;
    if (!Hive.isAdapterRegistered(221)) {
      Hive.registerAdapter(VitalRecordAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<VitalRecord>(_boxName);
    }
    _initialized = true;
  }

  Box<VitalRecord> get _box => Hive.box<VitalRecord>(_boxName);

  List<VitalRecord> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<VitalRecord> getForMember(String memberId) =>
      getAll().where((v) => v.memberId == memberId).toList();

  List<VitalRecord> getByType(String memberId, String type) =>
      getForMember(memberId).where((v) => v.type == type).toList();

  VitalRecord? getLatest(String memberId, String type) {
    final list = getByType(memberId, type);
    return list.isEmpty ? null : list.first;
  }

  Future<void> addOrUpdate(VitalRecord r) => _box.put(r.id, r);
  Future<void> delete(String id) => _box.delete(id);
}
