import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Emergency card screen showing emergency contact information
class EmergencyCardScreen extends StatefulWidget {
  const EmergencyCardScreen({super.key});

  @override
  State<EmergencyCardScreen> createState() => _EmergencyCardScreenState();
}

class _EmergencyCardScreenState extends State<EmergencyCardScreen> {
  bool _isEditing = false;
  
  // Mock emergency data
  final Map<String, dynamic> _emergencyData = {
    'primaryContact': {
      'name': 'Dr. Sarah Johnson',
      'relation': 'Primary Care Physician',
      'phone': '+1 (555) 123-4567',
      'email': 'dr.johnson@healthcare.com',
    },
    'emergencyContact': {
      'name': 'John Smith',
      'relation': 'Spouse',
      'phone': '+1 (555) 987-6543',
      'email': 'john.smith@email.com',
    },
    'secondaryContact': {
      'name': 'Mary Smith',
      'relation': 'Sister',
      'phone': '+1 (555) 456-7890',
      'email': 'mary.smith@email.com',
    },
    'medicalInfo': {
      'bloodType': 'O+',
      'allergies': ['Penicillin', 'Shellfish'],
      'conditions': ['Hypertension', 'Diabetes Type 2'],
      'medications': ['Lisinopril 10mg', 'Metformin 500mg'],
      'insurance': 'Blue Cross Blue Shield - Policy #: BC123456789',
    },
    'preferences': {
      'hospital': 'City General Hospital',
      'organDonor': true,
      'language': 'English',
      'religion': 'Christian',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.emergencyCard),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                AppUtils.showSuccessSnackBar(context, 'Emergency card updated');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEmergencyCard,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildEmergencyHeader(),
          const SizedBox(height: 16),
          _buildContactSection(
            'Primary Care Physician',
            _emergencyData['primaryContact'],
            Icons.local_hospital,
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildContactSection(
            'Emergency Contact',
            _emergencyData['emergencyContact'],
            Icons.contact_emergency,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildContactSection(
            'Secondary Contact',
            _emergencyData['secondaryContact'],
            Icons.person,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMedicalInfoSection(),
          const SizedBox(height: 16),
          _buildPreferencesSection(),
          const SizedBox(height: 32),
          if (!_isEditing) ..[
            CustomButton(
              text: 'Call Emergency Services',
              onPressed: _callEmergencyServices,
              backgroundColor: Colors.red,
              icon: Icons.phone,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Call Primary Doctor',
                    onPressed: () => _makeCall(_emergencyData['primaryContact']['phone']),
                    backgroundColor: Colors.blue,
                    icon: Icons.call,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Call Emergency Contact',
                    onPressed: () => _makeCall(_emergencyData['emergencyContact']['phone']),
                    backgroundColor: Colors.orange,
                    icon: Icons.call,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.red, size: 32),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Medical Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'Show this card to medical personnel',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            QrCodeWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(
    String title,
    Map<String, dynamic> contact,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', contact['name'], Icons.person),
            _buildInfoRow('Relation', contact['relation'], Icons.family_restroom),
            _buildInfoRow('Phone', contact['phone'], Icons.phone, isCallable: true),
            _buildInfoRow('Email', contact['email'], Icons.email),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoSection() {
    final medical = _emergencyData['medicalInfo'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_information, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Medical Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Blood Type', medical['bloodType'], Icons.water_drop),
            _buildInfoRow('Insurance', medical['insurance'], Icons.credit_card),
            const SizedBox(height: 8),
            _buildListSection('Allergies', medical['allergies'], Icons.warning, Colors.red),
            const SizedBox(height: 8),
            _buildListSection('Medical Conditions', medical['conditions'], Icons.health_and_safety, Colors.orange),
            const SizedBox(height: 8),
            _buildListSection('Current Medications', medical['medications'], Icons.medication, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final prefs = _emergencyData['preferences'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Preferred Hospital', prefs['hospital'], Icons.local_hospital),
            _buildInfoRow('Language', prefs['language'], Icons.language),
            _buildInfoRow('Religion', prefs['religion'], Icons.church),
            _buildInfoRow(
              'Organ Donor',
              prefs['organDonor'] ? 'Yes' : 'No',
              prefs['organDonor'] ? Icons.favorite : Icons.heart_broken,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isCallable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: isCallable
                ? GestureDetector(
                    onTap: () => _makeCall(value),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) => Chip(
            label: Text(item),
            backgroundColor: color.withOpacity(0.1),
            labelStyle: TextStyle(color: color, fontSize: 12),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )).toList(),
        ),
      ],
    );
  }

  void _makeCall(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Call'),
        content: Text('Call $phoneNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppUtils.showSuccessSnackBar(context, 'Calling $phoneNumber...');
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _callEmergencyServices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: const Text('This will call emergency services (911). Only use in real emergencies.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppUtils.showSuccessSnackBar(context, 'Calling 911...');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Call 911'),
          ),
        ],
      ),
    );
  }

  void _shareEmergencyCard() {
    AppUtils.showSuccessSnackBar(context, 'Emergency card shared successfully');
  }
}

// Simple QR code placeholder widget
class QrCodeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code, size: 24),
          Text('QR', style: TextStyle(fontSize: 8)),
        ],
      ),
    );
  }
}