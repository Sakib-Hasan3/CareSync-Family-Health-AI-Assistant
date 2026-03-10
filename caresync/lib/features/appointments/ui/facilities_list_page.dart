import 'package:flutter/material.dart';
import '../models/facility.dart';
import 'facility_departments_page.dart';

class FacilitiesListPage extends StatelessWidget {
  final String divisionId;
  const FacilitiesListPage({super.key, required this.divisionId});

  @override
  Widget build(BuildContext context) {
    final facilities = Facility.sampleFacilitiesForDivision(divisionId);
    return Scaffold(
      appBar: AppBar(title: Text('Facilities — ${divisionId.toUpperCase()}')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: facilities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final f = facilities[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  f.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(f.location),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FacilityDepartmentsPage(facility: f),
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
