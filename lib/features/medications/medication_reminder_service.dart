import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'models/medication.dart';

class MedicationReminderService {
  static final MedicationReminderService _instance =
      MedicationReminderService._internal();
  factory MedicationReminderService() => _instance;
  MedicationReminderService._internal();

  late FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
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
    _isInitialized = true;
  }

  Future<void> scheduleDoseReminder(Medication med, DateTime doseTime) async {
    if (!_isInitialized) await initialize();

    // 5 minutes before desired time
    final reminder = tz.TZDateTime.from(
      doseTime,
      tz.local,
    ).subtract(const Duration(minutes: 5));
    final when = reminder.isBefore(tz.TZDateTime.now(tz.local))
        ? tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5))
        : reminder;

    final android = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for taking medications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    final details = NotificationDetails(android: android, iOS: ios);

    final title = '💊 ${med.name} due soon';
    final body =
        '${med.dosage} • ${med.frequency}${med.time.isNotEmpty ? ' • ${med.time}' : ''}';

    await _notifications.zonedSchedule(
      med.id.hashCode.abs() % 100000,
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'med://${med.id}',
    );
  }

  Future<void> cancelReminder(String medicationId) async {
    if (!_isInitialized) await initialize();
    await _notifications.cancel(medicationId.hashCode.abs() % 100000);
  }

  Future<void> showTest() async {
    if (!_isInitialized) await initialize();
    await _notifications.show(
      77777,
      'CareSync Test',
      'Medication reminder system working',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication Reminders',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
