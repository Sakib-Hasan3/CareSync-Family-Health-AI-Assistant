import 'package:hive/hive.dart';
import 'models/appointment.dart';

class AppointmentRepository {
  static const _boxName = 'appointments';
  Box<Appointment>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(202))
      Hive.registerAdapter(AppointmentAdapter());
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Appointment>(_boxName);
    } else {
      _box = Hive.box<Appointment>(_boxName);
    }
  }

  List<Appointment> getAll() => _box?.values.toList() ?? [];

  Future<void> addOrUpdate(Appointment a) async {
    if (_box == null) await init();
    await _box!.put(a.id, a);
  }

  /// Backwards-compatible create method used by older call-sites.
  Future<void> create(Appointment a) async => addOrUpdate(a);

  Future<void> delete(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  Appointment? getById(String id) => _box?.get(id);

  Future<void> close() async => await _box?.close();
}
