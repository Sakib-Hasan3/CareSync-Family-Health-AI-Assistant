import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

      // Android initialization
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      _initialized = true;
      developer.log('✅ Notification service initialized');
    } catch (e) {
      developer.log('❌ Error initializing notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Android 13+ permissions
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    // iOS permissions
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Schedule medication alarm
  Future<void> scheduleMedicationAlarm({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    bool dailyRepeat = true,
  }) async {
    await initialize();

    try {
      final id = medicationId.hashCode;
      final now = tz.TZDateTime.now(tz.local);
      var tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // If the scheduled time is in the past today, schedule for tomorrow
      if (tzScheduledTime.isBefore(now)) {
        if (dailyRepeat) {
          tzScheduledTime = tzScheduledTime.add(const Duration(days: 1));
        } else {
          developer.log('⚠️ Medication time is in the past, skipping');
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'medication_alarms',
        'Medication Alarms',
        channelDescription: 'Alarms for medication reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm_sound.aiff',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      if (dailyRepeat) {
        // Schedule daily repeating alarm
        await _notifications.zonedSchedule(
          id,
          '💊 Time to take your medication!',
          '$medicationName - $dosage',
          tzScheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'medication:$medicationId',
        );

        developer.log(
            '✅ Scheduled DAILY medication alarm for $medicationName at ${tzScheduledTime.hour}:${tzScheduledTime.minute}');
      } else {
        // Schedule one-time alarm
        await _notifications.zonedSchedule(
          id,
          '💊 Time to take your medication!',
          '$medicationName - $dosage',
          tzScheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'medication:$medicationId',
        );

        developer.log(
            '✅ Scheduled ONE-TIME medication alarm for $medicationName at $tzScheduledTime');
      }

      // Schedule a pre-reminder 15 minutes before
      final reminderTime =
          tzScheduledTime.subtract(const Duration(minutes: 15));
      if (reminderTime.isAfter(now)) {
        await _notifications.zonedSchedule(
          id + 10000,
          '⏰ Medication Reminder',
          '$medicationName in 15 minutes - $dosage',
          reminderTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'medication_reminder:$medicationId',
        );

        developer.log('✅ Scheduled 15-min pre-reminder');
      }
    } catch (e) {
      developer.log('❌ Error scheduling medication alarm: $e');
    }
  }

  /// Schedule appointment alarm
  Future<void> scheduleAppointmentAlarm({
    required String appointmentId,
    required String doctorName,
    required String specialty,
    required DateTime appointmentTime,
  }) async {
    await initialize();

    try {
      final id = appointmentId.hashCode;
      final tzAppointmentTime = tz.TZDateTime.from(appointmentTime, tz.local);
      final now = tz.TZDateTime.now(tz.local);

      if (tzAppointmentTime.isBefore(now)) {
        developer.log('⚠️ Appointment time is in the past, skipping');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'appointment_alarms',
        'Appointment Alarms',
        channelDescription: 'Alarms for doctor appointments',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm_sound.aiff',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Alarm 1 hour before
      final oneHourBefore =
          tzAppointmentTime.subtract(const Duration(hours: 1));
      if (oneHourBefore.isAfter(now)) {
        await _notifications.zonedSchedule(
          id,
          '🏥 Appointment in 1 hour',
          'Dr. $doctorName - $specialty',
          oneHourBefore,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'appointment:$appointmentId',
        );
        developer.log('✅ Scheduled appointment alarm 1 hour before');
      }

      // Alarm 30 minutes before
      final thirtyMinsBefore =
          tzAppointmentTime.subtract(const Duration(minutes: 30));
      if (thirtyMinsBefore.isAfter(now)) {
        await _notifications.zonedSchedule(
          id + 20000,
          '⏰ Appointment in 30 minutes',
          'Dr. $doctorName - $specialty\nTime to head out!',
          thirtyMinsBefore,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'appointment_reminder:$appointmentId',
        );
        developer.log('✅ Scheduled appointment alarm 30 mins before');
      }

      // Alarm 1 day before
      final oneDayBefore =
          tzAppointmentTime.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        await _notifications.zonedSchedule(
          id + 30000,
          '📅 Appointment Tomorrow',
          'Dr. $doctorName - $specialty\nDon\'t forget!',
          oneDayBefore,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'appointment_day_before:$appointmentId',
        );
        developer.log('✅ Scheduled appointment alarm 1 day before');
      }
    } catch (e) {
      developer.log('❌ Error scheduling appointment alarm: $e');
    }
  }

  /// Cancel medication alarm
  Future<void> cancelMedicationAlarm(String medicationId) async {
    final id = medicationId.hashCode;
    await _notifications.cancel(id);
    await _notifications.cancel(id + 10000); // Cancel pre-reminder
    developer.log('❌ Cancelled medication alarm for ID: $medicationId');
  }

  /// Cancel appointment alarm
  Future<void> cancelAppointmentAlarm(String appointmentId) async {
    final id = appointmentId.hashCode;
    await _notifications.cancel(id);
    await _notifications.cancel(id + 20000);
    await _notifications.cancel(id + 30000);
    developer.log('❌ Cancelled appointment alarm for ID: $appointmentId');
  }

  /// Cancel all alarms
  Future<void> cancelAllAlarms() async {
    await _notifications.cancelAll();
    developer.log('❌ Cancelled all alarms');
  }

  /// Get pending alarms
  Future<List<PendingNotificationRequest>> getPendingAlarms() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'general_notifications',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
