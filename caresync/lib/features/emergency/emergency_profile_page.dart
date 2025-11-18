import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmergencyProfilePage extends StatefulWidget {
  const EmergencyProfilePage({super.key});

  @override
  State<EmergencyProfilePage> createState() => _EmergencyProfilePageState();
}

class _EmergencyProfilePageState extends State<EmergencyProfilePage> {
  final List<EmergencyProfile> _profiles = [
    EmergencyProfile(
      id: '1',
      name: 'John Smith',
      bloodGroup: 'O+',
      emergencyContact: '+1 (555) 123-4567',
      medicalConditions: ['Hypertension', 'Diabetes Type 2'],
      medications: ['Metformin 500mg', 'Lisinopril 10mg'],
      allergies: ['Penicillin', 'Shellfish'],
      primaryDoctor: 'Dr. Sarah Johnson',
      insuranceInfo: 'AETNA - PPO 123456',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    EmergencyProfile(
      id: '2',
      name: 'Maria Garcia',
      bloodGroup: 'A-',
      emergencyContact: '+1 (555) 987-6543',
      medicalConditions: ['Asthma'],
      medications: ['Albuterol Inhaler'],
      allergies: ['Latex'],
      primaryDoctor: 'Dr. Michael Chen',
      insuranceInfo: 'BLUE CROSS - HMO 789012',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Emergency Profiles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFDC143C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewProfile,
            tooltip: 'Add New Profile',
          ),
        ],
      ),
      body: _profiles.isEmpty ? _buildEmptyState() : _buildProfileList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              size: 50,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Emergency Profiles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Create emergency medical profiles for quick access during emergencies',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addNewProfile,
            icon: const Icon(Icons.add),
            label: const Text('Create First Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC143C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          _buildHeaderInfo(),
          const SizedBox(height: 24),

          // Profiles List
          ..._profiles.map((profile) => _buildProfileCard(profile)),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Medical Info',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Quick access to critical medical information during emergencies',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(EmergencyProfile profile) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and blood group
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getBloodGroupColor(profile.bloodGroup),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      profile.bloodGroup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created ${DateFormat('MMM dd, yyyy').format(profile.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleProfileAction(value, profile),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View Details')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Info Grid
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              children: [
                _buildInfoItem('Emergency Contact', profile.emergencyContact, Icons.phone),
                _buildInfoItem('Primary Doctor', profile.primaryDoctor, Icons.medical_services),
                _buildInfoItem('Medical Conditions', '${profile.medicalConditions.length}', Icons.health_and_safety),
                _buildInfoItem('Allergies', '${profile.allergies.length}', Icons.warning_amber_rounded),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewProfileDetails(profile),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareProfile(profile),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Profile'),
        content: const Text('This feature will allow you to create a new emergency medical profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to profile creation page
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _viewProfileDetails(EmergencyProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyProfileDetailPage(profile: profile),
      ),
    );
  }

  void _shareProfile(EmergencyProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Profile'),
        content: Text('Share ${profile.name}\'s emergency medical information?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${profile.name}\'s profile shared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _handleProfileAction(String action, EmergencyProfile profile) {
    switch (action) {
      case 'view':
        _viewProfileDetails(profile);
        break;
      case 'edit':
        // Navigate to edit page
        break;
      case 'share':
        _shareProfile(profile);
        break;
      case 'delete':
        _deleteProfile(profile);
        break;
    }
  }

  void _deleteProfile(EmergencyProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete ${profile.name}\'s emergency profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _profiles.remove(profile);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${profile.name}\'s profile deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getBloodGroupColor(String bloodGroup) {
    final colors = {
      'A+': const Color(0xFFDC143C),
      'A-': const Color(0xFFC2185B),
      'B+': const Color(0xFF2196F3),
      'B-': const Color(0xFF1976D2),
      'AB+': const Color(0xFF4CAF50),
      'AB-': const Color(0xFF388E3C),
      'O+': const Color(0xFFFF9800),
      'O-': const Color(0xFFF57C00),
    };
    return colors[bloodGroup] ?? const Color(0xFF1565C0);
  }
}

class EmergencyProfile {
  final String id;
  final String name;
  final String bloodGroup;
  final String emergencyContact;
  final List<String> medicalConditions;
  final List<String> medications;
  final List<String> allergies;
  final String primaryDoctor;
  final String insuranceInfo;
  final DateTime createdAt;

  EmergencyProfile({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.emergencyContact,
    required this.medicalConditions,
    required this.medications,
    required this.allergies,
    required this.primaryDoctor,
    required this.insuranceInfo,
    required this.createdAt,
  });
}

// Detail Page for Emergency Profile
class EmergencyProfileDetailPage extends StatelessWidget {
  final EmergencyProfile profile;

  const EmergencyProfileDetailPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Emergency Profile Details'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailCard(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(EmergencyProfile profile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            _buildDetailItem('Full Name', profile.name),
            _buildDetailItem('Blood Group', profile.bloodGroup),
            _buildDetailItem('Emergency Contact', profile.emergencyContact),
            _buildDetailItem('Primary Doctor', profile.primaryDoctor),
            _buildDetailItem('Insurance', profile.insuranceInfo),
            
            const SizedBox(height: 16),
            _buildListSection('Medical Conditions', profile.medicalConditions),
            _buildListSection('Medications', profile.medications),
            _buildListSection('Allergies', profile.allergies),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 6, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}