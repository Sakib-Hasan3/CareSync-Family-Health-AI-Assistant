import 'package:flutter/material.dart';
import 'facilities_list_page.dart';

class DivisionSelectionPage extends StatelessWidget {
  const DivisionSelectionPage({super.key});

  static const List<String> _divisions = [
    'Dhaka',
    'Chattogram',
    'Barishal',
    'Sylhet',
    'Khulna',
    'Rajshahi',
    'Mymensingh',
    'Rangpur',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Division')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _divisions.length,
          itemBuilder: (context, i) {
            final name = _divisions[i];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade50,
                foregroundColor: Colors.teal.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      FacilitiesListPage(divisionId: name.toLowerCase()),
                ),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
