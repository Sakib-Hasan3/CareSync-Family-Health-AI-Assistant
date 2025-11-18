import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/department.dart';
import 'booking_payment_page.dart';

class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;
  final Department department;
  const DoctorDetailPage({
    super.key,
    required this.doctor,
    required this.department,
  });

  List<TimeOfDay> _slotsForDay(DateTime day) {
    return [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 30),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final experience = (doctor.id.hashCode.abs() % 10) + 1;
    final today = DateTime.now();
    final slots = _slotsForDay(today);
    return Scaffold(
      appBar: AppBar(title: Text(doctor.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: doctor.photoUrl != null
                          ? NetworkImage(doctor.photoUrl!)
                          : null,
                      child: doctor.photoUrl == null
                          ? Text(
                              doctor.name
                                  .split(' ')
                                  .map((s) => s[0])
                                  .take(2)
                                  .join(),
                              style: const TextStyle(fontSize: 18),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              const Text('4.6'),
                              const SizedBox(width: 12),
                              Text('$experience yrs experience'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Available today',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: slots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final t = slots[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingPaymentPage(
                          doctor: doctor,
                          department: department,
                          initialDate: today,
                          initialTime: t,
                        ),
                      ),
                    ),
                    child: Chip(
                      label: Text(t.format(context)),
                      backgroundColor: Colors.teal.shade50,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Experienced ${doctor.specialty} at ${doctor.clinic}. Available for consultations and follow-ups.',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BookingPaymentPage(
                      doctor: doctor,
                      department: department,
                    ),
                  ),
                ),
                child: const Text('Book Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20B2AA),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
