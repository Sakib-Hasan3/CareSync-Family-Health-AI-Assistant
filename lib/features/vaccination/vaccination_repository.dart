import 'package:hive/hive.dart';
import 'models/vaccination_record.dart';

class VaccinationRepository {
  static const String _boxName = 'vaccination_records';
  Box<VaccinationRecord>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(220)) {
      Hive.registerAdapter(VaccinationRecordAdapter());
    }
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<VaccinationRecord>(_boxName);
    } else {
      _box = await Hive.openBox<VaccinationRecord>(_boxName);
    }
  }

  List<VaccinationRecord> getAll() => _box?.values.toList() ?? [];

  List<VaccinationRecord> getForMember(String memberId) =>
      getAll().where((r) => r.memberId == memberId).toList();

  List<VaccinationRecord> getUpcoming({int daysAhead = 30}) {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: daysAhead));
    return getAll()
        .where(
          (r) =>
              r.nextDueDate != null &&
              r.nextDueDate!.isAfter(now) &&
              r.nextDueDate!.isBefore(cutoff),
        )
        .toList()
      ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
  }

  List<VaccinationRecord> getOverdue() {
    final now = DateTime.now();
    return getAll()
        .where((r) => r.nextDueDate != null && r.nextDueDate!.isBefore(now))
        .toList()
      ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
  }

  Future<void> addOrUpdate(VaccinationRecord record) async {
    await _box?.put(record.id, record);
  }

  Future<void> delete(String id) async {
    await _box?.delete(id);
  }

  VaccinationRecord? getById(String id) => _box?.get(id);
}
