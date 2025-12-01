import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationsAdminPage extends StatefulWidget {
  const MedicationsAdminPage({super.key});

  @override
  State<MedicationsAdminPage> createState() => _MedicationsAdminPageState();
}

class _MedicationsAdminPageState extends State<MedicationsAdminPage> {
  final _firestore = FirebaseFirestore.instance;
  final _nameCtrl = TextEditingController();
  final _genericNameCtrl = TextEditingController();
  final _manufacturerCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _usesCtrl = TextEditingController();
  final _sideEffectsCtrl = TextEditingController();
  final _precautionsCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Database'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Medication',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Brand Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _genericNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Generic Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _manufacturerCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Manufacturer',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _typeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Type (Tablet, Capsule, Syrup, etc.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _dosageCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Dosage Strength',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 500mg, 10ml',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Uses (comma separated)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _sideEffectsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Side Effects (comma separated)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _precautionsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Precautions (comma separated)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Price (BDT)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _addMedication,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Medication'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('medication_database').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final medications = snapshot.data!.docs;
                if (medications.isEmpty) {
                  return const Center(child: Text('No medications added yet'));
                }
                return ListView.builder(
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final doc = medications[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        title: Text(
                          data['brandName'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${data['genericName'] ?? ''} • ${data['type'] ?? ''}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Manufacturer', data['manufacturer']),
                                _buildInfoRow('Dosage', data['dosage']),
                                _buildInfoRow('Price', '৳${data['price'] ?? 'N/A'}'),
                                if (data['uses'] != null) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Uses:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text((data['uses'] as List).join(', ')),
                                ],
                                if (data['sideEffects'] != null) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Side Effects:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text((data['sideEffects'] as List).join(', ')),
                                ],
                                if (data['precautions'] != null) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Precautions:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text((data['precautions'] as List).join(', ')),
                                ],
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _deleteMedication(doc.id),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Future<void> _addMedication() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    try {
      await _firestore.collection('medication_database').add({
        'brandName': _nameCtrl.text.trim(),
        'genericName': _genericNameCtrl.text.trim(),
        'manufacturer': _manufacturerCtrl.text.trim(),
        'type': _typeCtrl.text.trim(),
        'dosage': _dosageCtrl.text.trim(),
        'uses': _usesCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'sideEffects': _sideEffectsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'precautions': _precautionsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _nameCtrl.clear();
      _genericNameCtrl.clear();
      _manufacturerCtrl.clear();
      _typeCtrl.clear();
      _dosageCtrl.clear();
      _usesCtrl.clear();
      _sideEffectsCtrl.clear();
      _precautionsCtrl.clear();
      _priceCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully')),
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

  Future<void> _deleteMedication(String id) async {
    await _firestore.collection('medication_database').doc(id).delete();
  }
}
