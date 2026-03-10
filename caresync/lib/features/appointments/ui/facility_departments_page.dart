import 'package:flutter/material.dart';
import '../models/facility.dart';
import 'doctors_list_page.dart';

class FacilityDepartmentsPage extends StatelessWidget {
  final Facility facility;
  const FacilityDepartmentsPage({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    final deps = facility.departments;
    return Scaffold(
      appBar: AppBar(title: Text(facility.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: deps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final d = deps[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade50,
                  child: Text(d.name[0]),
                ),
                title: Text(
                  d.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(d.description),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DoctorsListPage(department: d, facility: facility),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
