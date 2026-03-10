import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/doctor.dart';
import 'models/appointment.dart';
import 'appointment_repository.dart';
import 'appointment_confirmation_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppointmentRepository _repo = AppointmentRepository();
  DateTime _focused = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Doctor? _selectedDoctor = sampleDoctors.first;

  @override
  void initState() {
    super.initState();
    _repo.init();
  }

  List<TimeOfDay> _availableSlotsFor(DateTime day) {
    // Simple demo: 9:00, 10:00, 11:00, 14:00, 15:00
    return [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 30),
    ];
  }

  void _bookSlot(TimeOfDay t) async {
    if (_selectedDoctor == null) return;
    final dt = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      t.hour,
      t.minute,
    );
    final appt = Appointment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      doctorId: _selectedDoctor!.id,
      doctorName: _selectedDoctor!.name,
      specialty: _selectedDoctor!.specialty,
      clinic: _selectedDoctor!.clinic,
      dateTime: dt,
    );
    await _repo.create(appt);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentConfirmationPage(appointment: appt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: sampleDoctors.length,
              itemBuilder: (context, i) {
                final d = sampleDoctors[i];
                final selected = _selectedDoctor?.id == d.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDoctor = d),
                  child: Card(
                    color: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(
                                d.name
                                    .split(' ')
                                    .map((s) => s[0])
                                    .take(2)
                                    .join(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    d.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    d.specialty,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    d.clinic,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focused,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              onDaySelected: (s, f) => setState(() {
                _selectedDay = s;
                _focused = f;
              }),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Available slots',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _availableSlotsFor(_selectedDay).length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final t = _availableSlotsFor(_selectedDay)[i];
                final label = t.format(context);
                return ListTile(
                  title: Text(label),
                  subtitle: Text(_selectedDoctor?.clinic ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () => _bookSlot(t),
                    child: const Text('Book'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
