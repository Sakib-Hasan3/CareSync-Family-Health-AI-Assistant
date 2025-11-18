import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/appointment.dart';

class AppointmentConfirmationPage extends StatelessWidget {
  final Appointment appointment;

  const AppointmentConfirmationPage({super.key, required this.appointment});

  String _formatLocal(DateTime dt) => DateFormat.yMMMMd().add_jm().format(dt);

  String _toGoogleCalendarUtcRange(
    DateTime start, {
    Duration duration = const Duration(hours: 1),
  }) {
    final utcStart = start.toUtc();
    final utcEnd = start.add(duration).toUtc();
    String fmt(DateTime d) => DateFormat("yyyyMMdd'T'HHmmss'Z'").format(d);
    return '${fmt(utcStart)}/${fmt(utcEnd)}';
  }

  Future<void> _openGoogleCalendar(BuildContext ctx) async {
    final title = Uri.encodeComponent(
      'Appointment with ${appointment.doctorName}',
    );
    final dates = _toGoogleCalendarUtcRange(appointment.dateTime);
    final details = Uri.encodeComponent(
      'Clinic: ${appointment.clinic}\nSpecialty: ${appointment.specialty}',
    );
    final url =
        'https://www.google.com/calendar/render?action=TEMPLATE&text=$title&dates=$dates&details=$details';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Could not open Google Calendar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 12),
            Text(
              'Booked with ${appointment.doctorName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${appointment.specialty} • ${appointment.clinic}'),
            const SizedBox(height: 8),
            Text('When: ${_formatLocal(appointment.dateTime)}'),
            const SizedBox(height: 16),
            if (appointment.notes != null) Text('Notes: ${appointment.notes}'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _openGoogleCalendar(context),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Add to Google Calendar'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
