import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../medications/medication_repository.dart';
import '../medical_records/medical_record_repository.dart';
import '../appointments/appointment_repository.dart';
import 'alert_repository.dart';
import 'models/smart_alert.dart';

/// SmartAlertService analyzes local data and creates alerts.
class SmartAlertService {
  static final SmartAlertService _instance = SmartAlertService._internal();
  factory SmartAlertService() => _instance;
  SmartAlertService._internal();

  final AlertRepository _alerts = AlertRepository();
  final MedicationRepository _medRepo = MedicationRepository();
  final MedicalRecordRepository _recRepo = MedicalRecordRepository();
  final AppointmentRepository _aptRepo = AppointmentRepository();

  late FlutterLocalNotificationsPlugin _notifications;
  bool _inited = false;

  Future<void> initialize() async {
    if (_inited) return;
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _notifications = FlutterLocalNotificationsPlugin();
    await _notifications.initialize(settings);

    await _alerts.init();
    await _medRepo.init();
    await _recRepo.init();
    await _aptRepo.init();

    _inited = true;
  }

  /// Run analysis rules and create alerts.
  Future<void> analyzeAndAlert() async {
    if (!_inited) await initialize();

    final now = DateTime.now();

    // Rule 1: Medication low stock
    final meds = _medRepo.getAll();
    for (final m in meds) {
      try {
        if (m.remaining <= m.refillThreshold) {
          final id = 'med_low_${m.id}';
          if (!_alertExists(id)) {
            final a = SmartAlert(
              id: id,
              type: 'medication_low',
              title: 'Low medication: ${m.name}',
              message:
                  '${m.name} has only ${m.remaining} doses left. Consider restocking.',
              referenceId: m.id,
            );
            await _alerts.add(a);
            await _showNotification(a);
          }
        }
      } catch (_) {}
    }

    // Rule 2: Upcoming appointments within 7 days
    final apts = _aptRepo.getAll();
    for (final ap in apts) {
      try {
        final diff = ap.datetime.difference(now).inDays;
        if (diff >= 0 && diff <= 7) {
          final id = 'apt_upcoming_${ap.id}';
          if (!_alertExists(id)) {
            final a = SmartAlert(
              id: id,
              type: 'appointment_upcoming',
              title: 'Upcoming appointment',
              message:
                  'Appointment with ${ap.doctor} on ${_fmtDate(ap.datetime)} at ${_fmtTime(ap.datetime)}',
              referenceId: ap.id,
            );
            await _alerts.add(a);
            await _showNotification(a);
          }
        }
      } catch (_) {}
    }

    // Rule 3: Vaccine records dated within next 7 days
    final recs = _recRepo.getAll();
    for (final r in recs) {
      try {
        if (r.type.toLowerCase().contains('vaccine') ||
            r.type.toLowerCase().contains('vaccination')) {
          final diff = r.date.difference(now).inDays;
          if (diff >= 0 && diff <= 7) {
            final id = 'vaccine_due_${r.id}';
            if (!_alertExists(id)) {
              final a = SmartAlert(
                id: id,
                type: 'vaccine_due',
                title: 'Vaccine due: ${r.title}',
                message:
                    'Vaccine "${r.title}" is scheduled on ${_fmtDate(r.date)}',
                referenceId: r.id,
              );
              await _alerts.add(a);
              await _showNotification(a);
            }
          }
        }
      } catch (_) {}
    }
  }

  bool _alertExists(String id) {
    try {
      final list = _alerts.getAll();
      return list.any((a) => a.id == id && !a.acknowledged);
    } catch (_) {
      return false;
    }
  }

  Future<void> _showNotification(SmartAlert a) async {
    final android = AndroidNotificationDetails(
      'smart_alerts',
      'Smart Alerts',
      channelDescription: 'AI-powered health alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    final ios = const DarwinNotificationDetails();
    final details = NotificationDetails(android: android, iOS: ios);
    await _notifications.show(
      a.id.hashCode.abs() % 100000,
      a.title,
      a.message,
      details,
      payload: 'alert://${a.id}',
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _fmtTime(DateTime d) {
    final h = d.hour;
    final m = d.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h % 12 == 0 ? 12 : h % 12;
    return '$dh:${m.toString().padLeft(2, '0')} $period';
  }
}
