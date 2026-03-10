import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalInfoAdminPage extends StatefulWidget {
  const MedicalInfoAdminPage({super.key});

  @override
  State<MedicalInfoAdminPage> createState() => _MedicalInfoAdminPageState();
}

class _MedicalInfoAdminPageState extends State<MedicalInfoAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Symptoms'),
            Tab(text: 'Conditions'),
            Tab(text: 'Treatments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SymptomsTab(),
          ConditionsTab(),
          TreatmentsTab(),
        ],
      ),
    );
  }
}

// SYMPTOMS TAB
class SymptomsTab extends StatefulWidget {
  const SymptomsTab({super.key});

  @override
  State<SymptomsTab> createState() => _SymptomsTabState();
}

class _SymptomsTabState extends State<SymptomsTab> {
  final _firestore = FirebaseFirestore.instance;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  String _severity = 'mild';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Symptom',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Symptom Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Respiratory, Digestive',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _severity,
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'mild', child: Text('Mild')),
                      DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                      DropdownMenuItem(value: 'severe', child: Text('Severe')),
                      DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                    ],
                    onChanged: (v) => setState(() => _severity = v ?? 'mild'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addSymptom,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Symptom'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('symptoms').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final symptoms = snapshot.data!.docs;
              if (symptoms.isEmpty) {
                return const Center(child: Text('No symptoms added yet'));
              }
              return ListView.builder(
                itemCount: symptoms.length,
                itemBuilder: (context, index) {
                  final doc = symptoms[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name'] ?? ''),
                    subtitle: Text(data['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(data['severity'] ?? ''),
                          backgroundColor: _getSeverityColor(data['severity']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSymptom(doc.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity) {
      case 'mild':
        return Colors.green.shade100;
      case 'moderate':
        return Colors.orange.shade100;
      case 'severe':
        return Colors.red.shade100;
      case 'emergency':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade100;
    }
  }

  Future<void> _addSymptom() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    try {
      await _firestore.collection('symptoms').add({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'severity': _severity,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _nameCtrl.clear();
      _descCtrl.clear();
      _categoryCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Symptom added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteSymptom(String id) async {
    await _firestore.collection('symptoms').doc(id).delete();
  }
}

// CONDITIONS TAB
class ConditionsTab extends StatefulWidget {
  const ConditionsTab({super.key});

  @override
  State<ConditionsTab> createState() => _ConditionsTabState();
}

class _ConditionsTabState extends State<ConditionsTab> {
  final _firestore = FirebaseFirestore.instance;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _causesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Medical Condition',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Condition Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _symptomsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Common Symptoms (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _causesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Causes (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addCondition,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Condition'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('medical_conditions').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final conditions = snapshot.data!.docs;
              if (conditions.isEmpty) {
                return const Center(child: Text('No conditions added yet'));
              }
              return ListView.builder(
                itemCount: conditions.length,
                itemBuilder: (context, index) {
                  final doc = conditions[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      title: Text(
                        data['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(data['description'] ?? ''),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['symptoms'] != null) ...[
                                const Text(
                                  'Symptoms:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text((data['symptoms'] as List).join(', ')),
                                const SizedBox(height: 8),
                              ],
                              if (data['causes'] != null) ...[
                                const Text(
                                  'Causes:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text((data['causes'] as List).join(', ')),
                              ],
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _deleteCondition(doc.id),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addCondition() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    try {
      await _firestore.collection('medical_conditions').add({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'symptoms': _symptomsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'causes': _causesCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _nameCtrl.clear();
      _descCtrl.clear();
      _symptomsCtrl.clear();
      _causesCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Condition added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteCondition(String id) async {
    await _firestore.collection('medical_conditions').doc(id).delete();
  }
}

// TREATMENTS TAB
class TreatmentsTab extends StatefulWidget {
  const TreatmentsTab({super.key});

  @override
  State<TreatmentsTab> createState() => _TreatmentsTabState();
}

class _TreatmentsTabState extends State<TreatmentsTab> {
  final _firestore = FirebaseFirestore.instance;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _procedureCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Treatment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Treatment Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _conditionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'For Condition',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _procedureCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Procedure (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addTreatment,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Treatment'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('treatments').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final treatments = snapshot.data!.docs;
              if (treatments.isEmpty) {
                return const Center(child: Text('No treatments added yet'));
              }
              return ListView.builder(
                itemCount: treatments.length,
                itemBuilder: (context, index) {
                  final doc = treatments[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name'] ?? ''),
                    subtitle: Text('For: ${data['condition'] ?? ''}\n${data['description'] ?? ''}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTreatment(doc.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addTreatment() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    try {
      await _firestore.collection('treatments').add({
        'name': _nameCtrl.text.trim(),
        'condition': _conditionCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'procedure': _procedureCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _nameCtrl.clear();
      _conditionCtrl.clear();
      _descCtrl.clear();
      _procedureCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteTreatment(String id) async {
    await _firestore.collection('treatments').doc(id).delete();
  }
}
