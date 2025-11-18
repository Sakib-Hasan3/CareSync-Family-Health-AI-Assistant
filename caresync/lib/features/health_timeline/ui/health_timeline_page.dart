import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../health_timeline_service.dart';
import '../models/timeline_event.dart';
import 'package:caresync/features/health_timeline/iconsax_stub.dart';
import 'package:caresync/features/appointments/appointments_page.dart';
import 'package:caresync/features/medications/medications_page.dart';
import 'package:caresync/features/medical_records/medical_records_page.dart';

class HealthTimelinePage extends StatefulWidget {
  const HealthTimelinePage({super.key});

  @override
  State<HealthTimelinePage> createState() => _HealthTimelinePageState();
}

class _HealthTimelinePageState extends State<HealthTimelinePage> {
  final HealthTimelineService _service = HealthTimelineService();
  late Future<List<TimelineEvent>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchTimeline();
  }

  String _dateKey(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  IconData _iconForType(TimelineEventType t) {
    switch (t) {
      case TimelineEventType.appointment:
        return Iconsax.calendar;
      case TimelineEventType.medication:
        return Iconsax.health;
      case TimelineEventType.medicalRecord:
        return Iconsax.document;
      case TimelineEventType.alert:
        return Iconsax.notification;
      case TimelineEventType.symptom:
      case TimelineEventType.vitals:
        return Iconsax.activity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Timeline')),
      body: FutureBuilder<List<TimelineEvent>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No events yet'));
          }

          // Group by date string
          final Map<String, List<TimelineEvent>> grouped = {};
          for (final e in events) {
            final k = _dateKey(e.timestamp.toLocal());
            grouped.putIfAbsent(k, () => []).add(e);
          }

          final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: keys.length,
            itemBuilder: (context, idx) {
              final dateKey = keys[idx];
              final list = grouped[dateKey]!;
              final displayDate = DateFormat.yMMMMd().format(
                DateTime.parse(dateKey),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    displayDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...list.map((e) => _buildEventTile(e)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventTile(TimelineEvent e) {
    final time = DateFormat.jm().format(e.timestamp.toLocal());
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(_iconForType(e.type), color: Colors.blue),
        ),
        title: Text(e.title),
        subtitle: e.subtitle != null ? Text(e.subtitle!) : null,
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () => _showEventDetail(e),
      ),
    );
  }

  void _showEventDetail(TimelineEvent e) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (e.subtitle != null) Text(e.subtitle!),
              const SizedBox(height: 12),
              Text(
                'When: ${DateFormat.yMMMd().add_jm().format(e.timestamp.toLocal())}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Basic navigation hooks: open related feature page for deeper view
                      switch (e.type) {
                        case TimelineEventType.appointment:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AppointmentsPage(),
                            ),
                          );
                          break;
                        case TimelineEventType.medication:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MedicationsPage(),
                            ),
                          );
                          break;
                        case TimelineEventType.medicalRecord:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MedicalRecordsPage(),
                            ),
                          );
                          break;
                        case TimelineEventType.alert:
                        case TimelineEventType.symptom:
                        case TimelineEventType.vitals:
                          // No direct detail page yet; just close.
                          break;
                      }
                    },
                    child: const Text('Open'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// navigation imports are at the top of the file
