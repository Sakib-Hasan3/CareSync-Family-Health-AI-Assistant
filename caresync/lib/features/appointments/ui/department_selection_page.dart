import 'package:flutter/material.dart';
import '../models/department.dart';
import 'doctors_list_page.dart';

class DepartmentSelectionPage extends StatelessWidget {
  const DepartmentSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final depts = Department.sampleDepartments();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Department')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: depts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final d = depts[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: _buildIcon(d.iconName),
                title: Text(
                  d.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(d.description),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DoctorsListPage(department: d),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(String name) {
    // simple mapping to built-in icons; expand as needed
    final map = {
      'heart': Icons.favorite,
      'skin': Icons.spa,
      'stethoscope': Icons.medical_services,
    };
    final icon = map[name] ?? Icons.local_hospital;
    return CircleAvatar(
      backgroundColor: Colors.teal.shade50,
      child: Icon(icon, color: Colors.teal.shade700),
    );
  }
}
