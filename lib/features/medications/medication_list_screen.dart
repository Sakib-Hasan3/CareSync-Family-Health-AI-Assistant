import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

/// Medication list screen
class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _activeMedications = [
    {
      'name': 'Lisinopril',
      'dosage': '10mg',
      'frequency': 'Once daily',
      'nextDose': '8:00 AM',
      'remaining': 25,
      'prescribedBy': 'Dr. Smith',
    },
    {
      'name': 'Metformin',
      'dosage': '500mg',
      'frequency': 'Twice daily',
      'nextDose': '12:00 PM',
      'remaining': 60,
      'prescribedBy': 'Dr. Johnson',
    },
  ];

  final List<Map<String, dynamic>> _pastMedications = [
    {
      'name': 'Amoxicillin',
      'dosage': '500mg',
      'frequency': 'Three times daily',
      'completedDate': '2024-02-15',
      'prescribedBy': 'Dr. Brown',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.medicationList),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.medication)),
            Tab(text: 'Past', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-medication');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: AppStrings.addMedication,
              icon: Icons.add,
              onPressed: () {
                Navigator.of(context).pushNamed('/add-medication');
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildActiveMedications(), _buildPastMedications()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveMedications() {
    if (_activeMedications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active medications'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _activeMedications.length,
      itemBuilder: (context, index) {
        final medication = _activeMedications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        medication['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editMedication(index);
                        } else if (value == 'delete') {
                          _deleteMedication(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${medication['dosage']} • ${medication['frequency']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prescribed by: ${medication['prescribedBy']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Next: ${medication['nextDose']}',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${medication['remaining']} pills left',
                      style: TextStyle(
                        color: medication['remaining'] < 10
                            ? Colors.red
                            : Colors.grey[600],
                        fontWeight: medication['remaining'] < 10
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastMedications() {
    if (_pastMedications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No past medications'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _pastMedications.length,
      itemBuilder: (context, index) {
        final medication = _pastMedications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.medication, color: Colors.white),
            ),
            title: Text(medication['name'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${medication['dosage']} • ${medication['frequency']}'),
                Text('Completed: ${medication['completedDate']}'),
              ],
            ),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }

  void _editMedication(int index) {
    Navigator.of(context).pushNamed(
      '/add-medication',
      arguments: {
        'isEdit': true,
        'medication': _activeMedications[index],
        'index': index,
      },
    );
  }

  void _deleteMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text(
          'Are you sure you want to remove ${_activeMedications[index]['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _activeMedications.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Medication removed')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
