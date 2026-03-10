import 'package:flutter/foundation.dart';
import 'models/timeline_event.dart';
import '../appointments/appointment_repository.dart';
import '../medications/medication_repository.dart';
import '../medical_records/medical_record_repository.dart';
import '../alerts/alert_repository.dart';

/// Service that aggregates events from several repositories and returns a
/// chronological list of `TimelineEvent` objects for the Health Timeline UI.
class HealthTimelineService {
  static final HealthTimelineService _instance =
      HealthTimelineService._internal();
  factory HealthTimelineService() => _instance;
  HealthTimelineService._internal();

  final AppointmentRepository _aptRepo = AppointmentRepository();
  final MedicationRepository _medRepo = MedicationRepository();
  final MedicalRecordRepository _recRepo = MedicalRecordRepository();
  final AlertRepository _alertRepo = AlertRepository();

  Future<void> _ensureInited() async {
    try {
      await _aptRepo.init();
    } catch (_) {}
    try {
      await _medRepo.init();
    } catch (_) {}
    try {
      await _recRepo.init();
    } catch (_) {}
    try {
      await _alertRepo.init();
    } catch (_) {}
  }

  /// Fetch timeline events merged from appointments, medications, medical
  /// records and alerts. Results are sorted descending (most recent first).
  Future<List<TimelineEvent>> fetchTimeline({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    await _ensureInited();

    final List<TimelineEvent> events = [];

    // Appointments
    try {
      final apts = _aptRepo.getAll();
      for (final a in apts) {
        final dt = a.datetime;
        if (_inRange(dt, from, to)) {
          events.add(
            TimelineEvent(
              id: 'apt:${a.id}',
              timestamp: dt,
              type: TimelineEventType.appointment,
              title: 'Appointment with ${a.doctorName}',
              subtitle: a.specialty ?? a.clinic,
              referenceId: a.id,
              meta: {'appointment': a},
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Timeline: appointment fetch error $e');
    }

    // Medications (use nextDose if present, otherwise ignore)
    try {
      final meds = _medRepo.getAll();
      for (final m in meds) {
        final dt = m.nextDose;
        if (dt == null) continue;
        if (_inRange(dt, from, to)) {
          events.add(
            TimelineEvent(
              id: 'med:${m.id}:${dt.toIso8601String()}',
              timestamp: dt,
              type: TimelineEventType.medication,
              title: 'Medication: ${m.name}',
              subtitle: '${m.dosage} • ${m.frequency}',
              referenceId: m.id,
              meta: {'medication': m},
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Timeline: medication fetch error $e');
    }

    // Medical Records
    try {
      final recs = _recRepo.getAll();
      for (final r in recs) {
        final dt = r.date;
        if (_inRange(dt, from, to)) {
          events.add(
            TimelineEvent(
              id: 'rec:${r.id}',
              timestamp: dt,
              type: TimelineEventType.medicalRecord,
              title: r.title,
              subtitle: r.type,
              referenceId: r.id,
              meta: {'record': r},
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Timeline: medical record fetch error $e');
    }

    // Smart Alerts
    try {
      final alerts = _alertRepo.getAll();
      for (final a in alerts) {
        final dt = a.createdAt;
        if (_inRange(dt, from, to)) {
          events.add(
            TimelineEvent(
              id: 'alert:${a.id}',
              timestamp: dt,
              type: TimelineEventType.alert,
              title: a.title,
              subtitle: a.message,
              referenceId: a.referenceId,
              meta: {'alert': a},
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Timeline: alert fetch error $e');
    }

    // Sort descending (most recent first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && events.length > limit)
      return events.take(limit).toList();
    return events;
  }

  bool _inRange(DateTime dt, DateTime? from, DateTime? to) {
    if (from != null && dt.isBefore(from)) return false;
    if (to != null && dt.isAfter(to)) return false;
    return true;
  }
}
