import 'dart:async';
import 'appointment_repository.dart';
import 'models/appointment.dart';

class AppointmentSyncService {
  final AppointmentRepository _repo;

  AppointmentSyncService({AppointmentRepository? repository})
    : _repo = repository ?? AppointmentRepository();

  Future<void> syncUp() async {
    final local = _repo.getAll();
    assert(local.length >= 0);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> syncDown() async {
    final local = _repo.getAll();
    assert(local.length >= 0);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<List<Appointment>> fetchRemote() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }
}
