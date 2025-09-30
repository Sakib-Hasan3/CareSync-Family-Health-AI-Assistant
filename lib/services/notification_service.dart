import 'dart:async';

/// Notification types
enum NotificationType {
  info,
  warning,
  error,
  success,
  medication,
  appointment,
  emergency,
}

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;
  final Map<String, dynamic>? data;
  final bool isRecurring;
  final Duration? recurringInterval;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    this.data,
    this.isRecurring = false,
    this.recurringInterval,
  });
}

/// Notification service for local and push notifications
abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermissions();
  Future<void> showNotification(AppNotification notification);
  Future<void> scheduleNotification(AppNotification notification);
  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
  Future<List<AppNotification>> getPendingNotifications();
  Stream<AppNotification> get onNotificationTapped;
}

/// Implementation of notification service
class NotificationServiceImpl implements NotificationService {
  final List<AppNotification> _pendingNotifications = [];
  final StreamController<AppNotification> _notificationTappedController =
      StreamController<AppNotification>.broadcast();
  bool _initialized = false;
  bool _permissionsGranted = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Simulate initialization
    await Future.delayed(const Duration(milliseconds: 200));
    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      throw Exception('NotificationService not initialized');
    }

    // Simulate permission request
    await Future.delayed(const Duration(seconds: 1));
    _permissionsGranted = true;
    return _permissionsGranted;
  }

  @override
  Future<void> showNotification(AppNotification notification) async {
    if (!_initialized || !_permissionsGranted) {
      throw Exception('Notifications not available');
    }

    // In real implementation, this would show an actual notification
    print('Showing notification: ${notification.title} - ${notification.body}');

    // Simulate notification tap after a delay
    Timer(const Duration(seconds: 2), () {
      _notificationTappedController.add(notification);
    });
  }

  @override
  Future<void> scheduleNotification(AppNotification notification) async {
    if (!_initialized || !_permissionsGranted) {
      throw Exception('Notifications not available');
    }

    // Add to pending notifications
    _pendingNotifications.add(notification);

    // In real implementation, this would schedule with the system
    print(
      'Scheduled notification: ${notification.title} for ${notification.scheduledTime}',
    );

    // If it's a recurring notification, handle the recurring logic
    if (notification.isRecurring && notification.recurringInterval != null) {
      _handleRecurringNotification(notification);
    }
  }

  @override
  Future<void> cancelNotification(String id) async {
    _pendingNotifications.removeWhere((notification) => notification.id == id);
    print('Cancelled notification: $id');
  }

  @override
  Future<void> cancelAllNotifications() async {
    _pendingNotifications.clear();
    print('Cancelled all notifications');
  }

  @override
  Future<List<AppNotification>> getPendingNotifications() async {
    return List.from(_pendingNotifications);
  }

  @override
  Stream<AppNotification> get onNotificationTapped =>
      _notificationTappedController.stream;

  /// Handle recurring notifications
  void _handleRecurringNotification(AppNotification notification) {
    if (notification.recurringInterval == null) return;

    Timer.periodic(notification.recurringInterval!, (timer) {
      final nextNotification = AppNotification(
        id: '${notification.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: notification.title,
        body: notification.body,
        type: notification.type,
        scheduledTime: DateTime.now().add(notification.recurringInterval!),
        data: notification.data,
        isRecurring: true,
        recurringInterval: notification.recurringInterval,
      );

      showNotification(nextNotification);
    });
  }

  /// Helper methods for specific notification types

  /// Schedule medication reminder
  Future<void> scheduleMedicationReminder({
    required String medicationName,
    required DateTime reminderTime,
    required String dosage,
    bool isRecurring = true,
  }) async {
    final notification = AppNotification(
      id: 'med_${medicationName}_${reminderTime.millisecondsSinceEpoch}',
      title: 'Medication Reminder',
      body: 'Time to take $medicationName ($dosage)',
      type: NotificationType.medication,
      scheduledTime: reminderTime,
      data: {
        'medication': medicationName,
        'dosage': dosage,
        'type': 'medication_reminder',
      },
      isRecurring: isRecurring,
      recurringInterval: isRecurring ? const Duration(days: 1) : null,
    );

    await scheduleNotification(notification);
  }

  /// Schedule appointment reminder
  Future<void> scheduleAppointmentReminder({
    required String doctorName,
    required DateTime appointmentTime,
    required String location,
  }) async {
    // Reminder 1 day before
    final dayBeforeNotification = AppNotification(
      id: 'apt_day_${appointmentTime.millisecondsSinceEpoch}',
      title: 'Appointment Tomorrow',
      body: 'Appointment with $doctorName at $location',
      type: NotificationType.appointment,
      scheduledTime: appointmentTime.subtract(const Duration(days: 1)),
      data: {
        'doctor': doctorName,
        'location': location,
        'appointment_time': appointmentTime.toIso8601String(),
        'type': 'appointment_reminder',
      },
    );

    // Reminder 1 hour before
    final hourBeforeNotification = AppNotification(
      id: 'apt_hour_${appointmentTime.millisecondsSinceEpoch}',
      title: 'Appointment in 1 Hour',
      body: 'Appointment with $doctorName at $location',
      type: NotificationType.appointment,
      scheduledTime: appointmentTime.subtract(const Duration(hours: 1)),
      data: {
        'doctor': doctorName,
        'location': location,
        'appointment_time': appointmentTime.toIso8601String(),
        'type': 'appointment_reminder',
      },
    );

    await scheduleNotification(dayBeforeNotification);
    await scheduleNotification(hourBeforeNotification);
  }

  /// Send emergency notification
  Future<void> sendEmergencyNotification({
    required String message,
    required String contactInfo,
  }) async {
    final notification = AppNotification(
      id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Emergency Alert',
      body: message,
      type: NotificationType.emergency,
      scheduledTime: DateTime.now(),
      data: {'contact_info': contactInfo, 'type': 'emergency'},
    );

    await showNotification(notification);
  }

  void dispose() {
    _notificationTappedController.close();
  }
}
