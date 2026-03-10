import 'package:flutter/material.dart';
import 'family_repository.dart';
import 'family_color_repository.dart';
import 'models/family_member_model.dart';
import 'edit_family_member_page.dart';

class FamilyProfilesPage extends StatefulWidget {
  const FamilyProfilesPage({super.key});

  @override
  State<FamilyProfilesPage> createState() => _FamilyProfilesPageState();
}

class _FamilyProfilesPageState extends State<FamilyProfilesPage> {
  final FamilyRepository repo = FamilyRepository();
  final FamilyColorRepository colorRepo = FamilyColorRepository();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await repo.init();
    await colorRepo.init();
    setState(() => _loading = false);
  }

  Future<void> _refreshData() async {
    setState(() => _loading = true);
    await repo.init();
    setState(() => _loading = false);
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: Text(
          'Are you sure you want to delete ${member.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await repo.delete(member.id);
      if (mounted) setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.name} removed from family'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showMemberOptions(FamilyMember member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _editMember(member);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.palette_rounded, color: Color(0xFF8B5CF6), size: 20),
              ),
              title: const Text('Choose Color'),
              onTap: () {
                Navigator.pop(context);
                _pickColor(member);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.red, size: 20),
              ),
              title: const Text(
                'Delete Member',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteMember(member);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _editMember(FamilyMember member) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditFamilyMemberPage(member: member)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _pickColor(FamilyMember member) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color for ${member.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: FamilyColorRepository.palette.map((color) {
                final isCurrent = colorRepo.getColor(member.id).value == color.value;
                return GestureDetector(
                  onTap: () async {
                    await colorRepo.setColor(member.id, color);
                    if (mounted) setState(() {});
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isCurrent ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)] : null,
                    ),
                    child: isCurrent ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewMember() async {
    final newMember = FamilyMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditFamilyMemberPage(member: newMember, isNew: true),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final members = repo.getAll();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    title: const Text(
                      'Family Profiles',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    pinned: true,
                    expandedHeight: 140,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Family Health Management',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${members.length} Family Member${members.length != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  if (members.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final member = members[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _FamilyMemberCard(
                              member: member,
                              color: colorRepo.getColor(member.id),
                              onTap: () => _editMember(member),
                              onOptions: () => _showMemberOptions(member),
                            ),
                          );
                        }, childCount: members.length),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMember,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.person_add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.people, size: 48, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const Text(
          'No Family Members',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Start by adding your first family member to manage their health information',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _addNewMember,
            icon: const Icon(Icons.person_add, size: 20),
            label: const Text('Add First Member'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onOptions;

  const _FamilyMemberCard({
    required this.member,
    required this.color,
    required this.onTap,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
            border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          ),
          child: Row(
            children: [
              // Avatar with member color
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 32),
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
                            member.bloodGroup,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // Health Summary
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (member.allergies.isNotEmpty)
                          _SummaryChip(
                            icon: Icons.warning_amber,
                            count: member.allergies.length,
                            label: 'Allergies',
                            color: Colors.orange,
                          ),
                        if (member.chronicDiseases.isNotEmpty)
                          _SummaryChip(
                            icon: Icons.favorite,
                            count: member.chronicDiseases.length,
                            label: 'Conditions',
                            color: Colors.red,
                          ),
                        if (member.medications.isNotEmpty)
                          _SummaryChip(
                            icon: Icons.local_hospital,
                            count: member.medications.length,
                            label: 'Meds',
                            color: Colors.blue,
                          ),
                        if (member.emergencyContacts.isNotEmpty)
                          _SummaryChip(
                            icon: Icons.call,
                            count: member.emergencyContacts.length,
                            label: 'Contacts',
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Options Button
              IconButton(
                onPressed: onOptions,
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.count,
    required this.label,
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
            '$count $label',
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
