import 'package:flutter/material.dart';
// iconsax removed; using Material icons
import 'models/family_member_model.dart';

class FamilyMembersPage extends StatefulWidget {
  const FamilyMembersPage({super.key});

  @override
  State<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

class _FamilyMembersPageState extends State<FamilyMembersPage> {
  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: '1',
      name: 'John Smith',
      bloodGroup: 'O+',
      allergies: ['Peanuts', 'Penicillin'],
      chronicDiseases: ['Hypertension'],
      medications: ['Lisinopril 10mg', 'Aspirin 81mg'],
      insurance: 'Blue Cross - PPO123',
      emergencyContacts: {'Spouse': '+1234567890', 'Doctor': '+0987654321'},
    ),
    FamilyMember(
      id: '2',
      name: 'Sarah Smith',
      bloodGroup: 'A+',
      allergies: ['Shellfish'],
      chronicDiseases: ['Asthma'],
      medications: ['Albuterol Inhaler'],
      insurance: 'Blue Cross - PPO123',
      emergencyContacts: {'Spouse': '+1234567890', 'Doctor': '+0987654321'},
    ),
    FamilyMember(
      id: '3',
      name: 'Emma Smith',
      bloodGroup: 'O+',
      allergies: ['Dust Mites'],
      medications: ['Children\'s Multivitamin'],
      insurance: 'Blue Cross - PPO123',
      emergencyContacts: {
        'Father': '+1234567890',
        'Pediatrician': '+1122334455',
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Family Members List
            Expanded(child: _buildFamilyMembersList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFamilyMember,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.person_add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Family Members',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Manage health profiles for your entire family',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 24),

          // Members List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Family Members (${_familyMembers.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.sort, size: 20),
                tooltip: 'Sort',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Members List
          Expanded(
            child: ListView.builder(
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) {
                return _FamilyMemberCard(
                  member: _familyMembers[index],
                  onTap: () => _viewMemberDetails(_familyMembers[index]),
                  onEdit: () => _editFamilyMember(_familyMembers[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: const Color(0xFF2563EB).withOpacity(0.3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: _familyMembers.length.toString(),
            label: 'Members',
            icon: Icons.people,
          ),
          _StatItem(
            value: _getTotalMedications().toString(),
            label: 'Medications',
            icon: Icons.medication,
          ),
          _StatItem(
            value: _getTotalAllergies().toString(),
            label: 'Allergies',
            icon: Icons.warning_amber,
          ),
        ],
      ),
    );
  }

  int _getTotalMedications() {
    return _familyMembers.fold(
      0,
      (sum, member) => sum + member.medications.length,
    );
  }

  int _getTotalAllergies() {
    return _familyMembers.fold(
      0,
      (sum, member) => sum + member.allergies.length,
    );
  }

  void _addFamilyMember() {
    // Navigate to add family member screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddFamilyMemberSheet(
        onSave: (member) {
          setState(() {
            _familyMembers.add(member);
          });
        },
      ),
    );
  }

  void _viewMemberDetails(FamilyMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyMemberDetailPage(member: member),
      ),
    );
  }

  void _editFamilyMember(FamilyMember member) {
    // Navigate to edit screen
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _FamilyMemberCard({
    required this.member,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getAvatarColor(member.name),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),

                // Member Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (member.bloodGroup.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.bloodtype,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Blood Group: ${member.bloodGroup}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (member.allergies.isNotEmpty)
                            _InfoChip(
                              icon: Icons.warning_amber,
                              text: '${member.allergies.length} Allergies',
                              color: Colors.orange,
                            ),
                          if (member.medications.isNotEmpty)
                            _InfoChip(
                              icon: Icons.medication,
                              text: '${member.medications.length} Meds',
                              color: Colors.blue,
                            ),
                          if (member.chronicDiseases.isNotEmpty)
                            _InfoChip(
                              icon: Icons.favorite,
                              text:
                                  '${member.chronicDiseases.length} Conditions',
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit Button
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];
    return colors[name.hashCode % colors.length];
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Family Member Detail Page
class FamilyMemberDetailPage extends StatelessWidget {
  final FamilyMember member;

  const FamilyMemberDetailPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
            _buildDetailHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Card
                    _buildProfileCard(),
                    const SizedBox(height: 24),

                    // Medical Information Sections
                    _buildMedicalInfoSection(
                      'Allergies',
                      member.allergies,
                      Icons.warning_amber,
                      Colors.orange,
                    ),
                    const SizedBox(height: 20),

                    _buildMedicalInfoSection(
                      'Chronic Conditions',
                      member.chronicDiseases,
                      Icons.favorite,
                      Colors.red,
                    ),
                    const SizedBox(height: 20),

                    _buildMedicalInfoSection(
                      'Current Medications',
                      member.medications,
                      Icons.local_hospital,
                      Colors.blue,
                    ),
                    const SizedBox(height: 20),

                    _buildEmergencyContacts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 12),
          Text(
            member.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getAvatarColor(member.name),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            member.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          if (member.bloodGroup.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bloodtype, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Blood Group: ${member.bloodGroup}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (member.insurance.isNotEmpty)
            Text(
              member.insurance,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                '${items.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              'No $title recorded',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...items.map((item) => _MedicalInfoItem(text: item)).toList(),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.call, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (member.emergencyContacts.isEmpty)
            Text(
              'No emergency contacts added',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...member.emergencyContacts.entries
                .map(
                  (entry) => _EmergencyContactItem(
                    label: entry.key,
                    contact: entry.value,
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];
    return colors[name.hashCode % colors.length];
  }
}

class _MedicalInfoItem extends StatelessWidget {
  final String text;

  const _MedicalInfoItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactItem extends StatelessWidget {
  final String label;
  final String contact;

  const _EmergencyContactItem({required this.label, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call, color: Colors.green, size: 20),
          ),
        ],
      ),
    );
  }
}

// Add Family Member Bottom Sheet
class _AddFamilyMemberSheet extends StatefulWidget {
  final Function(FamilyMember) onSave;

  const _AddFamilyMemberSheet({required this.onSave});

  @override
  State<_AddFamilyMemberSheet> createState() => __AddFamilyMemberSheetState();
}

class __AddFamilyMemberSheetState extends State<_AddFamilyMemberSheet> {
  // Form state management would go here

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add Family Member',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          // Form fields would go here
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Save logic
                widget.onSave(
                  FamilyMember(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: 'New Member',
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Add Member',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
