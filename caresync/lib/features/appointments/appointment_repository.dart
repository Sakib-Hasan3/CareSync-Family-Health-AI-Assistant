import 'package:hive/hive.dart';
import 'models/appointment.dart';
import 'package:caresync/shared/services/notification_service.dart';

class AppointmentRepository {
  static const _boxName = 'appointments';
  Box<Appointment>? _box;
  final _notificationService = NotificationService();

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
    
    // Schedule alarm for appointment if in future
    if (a.datetime.isAfter(DateTime.now())) {
      await _notificationService.scheduleAppointmentAlarm(
        appointmentId: a.id,
        doctorName: a.doctor,
        specialty: a.specialty ?? 'Appointment',
        appointmentTime: a.datetime,
      );
    }
  }

  /// Backwards-compatible create method used by older call-sites.
  Future<void> create(Appointment a) async => addOrUpdate(a);

  Future<void> delete(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
    
    // Cancel alarm when appointment is deleted
    await _notificationService.cancelAppointmentAlarm(id);
  }

  Appointment? getById(String id) => _box?.get(id);

  Future<void> close() async => await _box?.close();
}
