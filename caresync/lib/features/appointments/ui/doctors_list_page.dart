import 'package:flutter/material.dart';
import '../models/department.dart';
import '../models/doctor.dart';
import '../models/facility.dart';
import 'doctor_detail_page.dart';

class DoctorsListPage extends StatelessWidget {
  final Department department;
  final Facility? facility;
  const DoctorsListPage({super.key, required this.department, this.facility});

  @override
  Widget build(BuildContext context) {
    final all = sampleDoctors;
    final onDuty = <Doctor>[];
    final offDuty = <Doctor>[];
    for (var i = 0; i < all.length; i++) {
      if (i % 2 == 0) {
        onDuty.add(all[i]);
      } else {
        offDuty.add(all[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${department.name}${facility != null ? ' • ${facility!.name}' : ''}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionHeader('On Duty', onDuty.length),
          const SizedBox(height: 8),
          ...onDuty.map((d) => _doctorCard(context, d, true)).toList(),
          const SizedBox(height: 16),
          _sectionHeader('Off Duty', offDuty.length),
          const SizedBox(height: 8),
          ...offDuty.map((d) => _doctorCard(context, d, false)).toList(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 8),
      if (count > 0) Chip(label: Text('$count')),
    ],
  );

  Widget _doctorCard(BuildContext context, Doctor d, bool onDuty) {
    final experience = (d.id.hashCode.abs() % 10) + 1;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundImage: d.photoUrl != null
              ? NetworkImage(d.photoUrl!)
              : null,
          child: d.photoUrl == null
              ? Text(d.name.split(' ').map((s) => s[0]).take(2).join())
              : null,
        ),
        title: Text(
          d.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${d.specialty} • $experience yrs'),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: onDuty ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                onDuty ? 'On Duty' : 'Off Duty',
                style: TextStyle(
                  color: onDuty ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: onDuty
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DoctorDetailPage(doctor: d, department: department),
                      ),
                    )
                  : null,
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}
