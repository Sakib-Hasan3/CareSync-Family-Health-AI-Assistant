import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'models/appointment.dart';

/// Singleton service to manage appointment reminders using
/// flutter_local_notifications and timezone-aware scheduling.
class AppointmentReminderService {
  static final AppointmentReminderService _instance =
      AppointmentReminderService._internal();
  factory AppointmentReminderService() => _instance;
  AppointmentReminderService._internal();

  late FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Configure platform settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    _notifications = FlutterLocalNotificationsPlugin();
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
  }

  /// Schedule a reminder for an appointment (timezone-aware)
  Future<void> scheduleReminder(Appointment appointment) async {
    if (!_isInitialized) await initialize();

    final reminderTime = _calculateReminderTime(appointment);

    final androidDetails = AndroidNotificationDetails(
      'appointment_reminders',
      'Appointment Reminders',
      channelDescription: 'Reminders for your medical appointments',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: const BigTextStyleInformation(''),
    );

    final iosDetails = const DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _getNotificationId(appointment.id),
      _getNotificationTitle(appointment),
      _getNotificationBody(appointment),
      reminderTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: _getNotificationPayload(appointment),
    );
  }

  Future<void> cancelReminder(String appointmentId) async {
    if (!_isInitialized) await initialize();
    await _notifications.cancel(_getNotificationId(appointmentId));
  }

  Future<void> cancelAllReminders() async {
    if (!_isInitialized) await initialize();
    await _notifications.cancelAll();
  }

  Future<void> rescheduleReminder(Appointment appointment) async {
    await cancelReminder(appointment.id);
    await scheduleReminder(appointment);
  }

  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    if (!_isInitialized) await initialize();
    return _notifications.pendingNotificationRequests();
  }

  Future<bool> isReminderScheduled(String appointmentId) async {
    final pending = await getPendingReminders();
    return pending.any((n) => n.id == _getNotificationId(appointmentId));
  }

  Future<void> scheduleMultipleReminders(
    Appointment appointment, {
    List<int>? reminderIntervals,
  }) async {
    final intervals = reminderIntervals ?? [1440, 60, 30];
    for (final minutes in intervals) {
      final ap = appointment.copyWith(reminderMinutesBefore: minutes);
      await scheduleReminder(ap);
    }
  }

  // Helpers
  tz.TZDateTime _calculateReminderTime(Appointment appointment) {
    final appointmentTime = tz.TZDateTime.from(appointment.datetime, tz.local);
    final reminderTime = appointmentTime.subtract(
      Duration(minutes: appointment.reminderMinutesBefore),
    );

    if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    }
    return reminderTime;
  }

  int _getNotificationId(String appointmentId) =>
      appointmentId.hashCode.abs() % 100000;

  String _getNotificationTitle(Appointment appointment) {
    if (appointment.reminderMinutesBefore >= 1440) {
      return '🩺 Appointment Tomorrow: ${appointment.title}';
    } else if (appointment.reminderMinutesBefore >= 60) {
      return '🩺 Appointment in ${appointment.reminderMinutesBefore ~/ 60} hours';
    } else {
      return '🩺 Appointment Now: ${appointment.title}';
    }
  }

  String _getNotificationBody(Appointment appointment) {
    final time = _formatTime(appointment.datetime);
    final date = _formatDate(appointment.datetime);
    var body = 'With ${appointment.doctor} at $time';
    if (appointment.location.isNotEmpty)
      body += '\nLocation: ${appointment.location}';
    if (appointment.reminderMinutesBefore >= 1440) body += '\nDate: $date';
    if ((appointment.notes ?? '').isNotEmpty)
      body += '\nNotes: ${appointment.notes}';
    return body;
  }

  String _getNotificationPayload(Appointment appointment) =>
      'appointment://${appointment.id}';

  String _formatTime(DateTime d) {
    final hour = d.hour;
    final minute = d.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.startsWith('appointment://')) {
      final appointmentId = payload.substring('appointment://'.length);
      // For now we just log; navigation requires app context.
      // ignore: avoid_print
      print('Notification tapped for appointment: $appointmentId');
    }
  }

  Future<void> showTestNotification() async {
    if (!_isInitialized) await initialize();
    final androidDetails = AndroidNotificationDetails(
      'appointment_reminders',
      'Appointment Reminders',
      channelDescription: 'Reminders',
    );
    final iosDetails = const DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(
      99999,
      '🩺 CareSync Test',
      'Appointment reminder system is working correctly!',
      details,
    );
  }

  Future<void> configureNotificationChannels() async {
    if (!_isInitialized) await initialize();
    const channel = AndroidNotificationChannel(
      'appointment_reminders',
      'Appointment Reminders',
      description: 'Reminders for your medical appointments',
      importance: Importance.high,
    );
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();
    try {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to request notification permissions: $e');
      return false;
    }
  }

  void dispose() {
    // nothing to dispose
  }
}
