import 'package:flutter/material.dart';
import 'package:caresync/shared/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmSettingsPage extends StatefulWidget {
  const AlarmSettingsPage({Key? key}) : super(key: key);

  @override
  State<AlarmSettingsPage> createState() => _AlarmSettingsPageState();
}

class _AlarmSettingsPageState extends State<AlarmSettingsPage> {
  final _notificationService = NotificationService();
  List<PendingNotificationRequest> _pendingAlarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingAlarms();
  }

  Future<void> _loadPendingAlarms() async {
    setState(() => _isLoading = true);
    try {
      final alarms = await _notificationService.getPendingAlarms();
      setState(() {
        _pendingAlarms = alarms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAlarm() async {
    await _notificationService.showImmediateNotification(
      id: 99999,
      title: '🔔 Test Alarm',
      body: 'This is a test notification!',
      payload: 'test',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _cancelAllAlarms() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel All Alarms?'),
        content: const Text(
          'This will cancel all pending medication and appointment alarms. You can reschedule them later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _notificationService.cancelAllAlarms();
      await _loadPendingAlarms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All alarms cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _getAlarmTypeIcon(String? payload) {
    if (payload == null) return '🔔';
    if (payload.contains('medication')) return '💊';
    if (payload.contains('appointment')) return '🏥';
    return '🔔';
  }

  String _getAlarmTypeText(String? payload) {
    if (payload == null) return 'General';
    if (payload.contains('medication')) {
      if (payload.contains('reminder')) return 'Medication Pre-Reminder';
      return 'Medication Alarm';
    }
    if (payload.contains('appointment')) {
      if (payload.contains('day_before')) return 'Appointment (1 Day Before)';
      if (payload.contains('reminder')) return 'Appointment (30 mins)';
      return 'Appointment (1 Hour Before)';
    }
    return 'General Alarm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingAlarms,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.alarm,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Alarms',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_pendingAlarms.length} scheduled',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _testAlarm,
                              icon: const Icon(Icons.notifications_active),
                              label: const Text('Test Alarm'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _pendingAlarms.isEmpty ? null : _cancelAllAlarms,
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancel All'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pending Alarms List
                Expanded(
                  child: _pendingAlarms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.alarm_off,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Active Alarms',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add medications or appointments\nto schedule alarms',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pendingAlarms.length,
                          itemBuilder: (context, index) {
                            final alarm = _pendingAlarms[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  child: Text(
                                    _getAlarmTypeIcon(alarm.payload),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                title: Text(
                                  alarm.title ?? 'Scheduled Alarm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    if (alarm.body != null)
                                      Text(
                                        alarm.body!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.category_outlined,
                                          size: 14,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getAlarmTypeText(alarm.payload),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.alarm,
                                        size: 16,
                                        color: Color(0xFF2563EB),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ID: ${alarm.id}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Info Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE047)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFCA8A04),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Alarms are automatically scheduled when you add medications or appointments',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
