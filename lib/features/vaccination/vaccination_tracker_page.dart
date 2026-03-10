import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../family_profiles/family_repository.dart';
import '../family_profiles/models/family_member_model.dart';
import 'models/vaccination_record.dart';
import 'vaccination_repository.dart';

// Common childhood & adult vaccine suggestions
const List<String> _kVaccineSuggestions = [
  'BCG',
  'Hepatitis B',
  'OPV (Oral Polio)',
  'Pentavalent (DTP-HepB-Hib)',
  'Pneumococcal (PCV)',
  'Rotavirus',
  'IPV (Inactivated Polio)',
  'Measles–Rubella (MR)',
  'MMR',
  'Varicella (Chickenpox)',
  'Japanese Encephalitis',
  'Typhoid',
  'Hepatitis A',
  'HPV',
  'Td (Tetanus-Diphtheria)',
  'Influenza (Flu)',
  'COVID-19',
  'Meningococcal',
  'Rabies',
];

class VaccinationTrackerPage extends StatefulWidget {
  const VaccinationTrackerPage({super.key});

  @override
  State<VaccinationTrackerPage> createState() => _VaccinationTrackerPageState();
}

class _VaccinationTrackerPageState extends State<VaccinationTrackerPage>
    with SingleTickerProviderStateMixin {
  final _repo = VaccinationRepository();
  final _familyRepo = FamilyRepository();

  late TabController _tabs;
  List<VaccinationRecord> _all = [];
  List<VaccinationRecord> _upcoming = [];
  List<VaccinationRecord> _overdue = [];
  List<FamilyMember> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _repo.init();
    try {
      await _familyRepo.init();
      _members = _familyRepo.getAll();
    } catch (_) {}
    setState(() {
      _all = _repo.getAll()
        ..sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
      _upcoming = _repo.getUpcoming(daysAhead: 60);
      _overdue = _repo.getOverdue();
      _loading = false;
    });
  }

  void _showAddSheet({VaccinationRecord? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VaccineFormSheet(
        existing: existing,
        members: _members,
        onSaved: (record) async {
          await _repo.addOrUpdate(record);
          await _load();
        },
      ),
    );
  }

  Future<void> _delete(VaccinationRecord r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Delete "${r.vaccineName}" for ${r.memberName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.delete(r.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Vaccination Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'All (${_all.length})',
              icon: const Icon(Icons.list_alt_rounded, size: 18),
            ),
            Tab(
              text: 'Upcoming (${_upcoming.length})',
              icon: const Icon(Icons.schedule_rounded, size: 18),
            ),
            Tab(
              text: 'Overdue (${_overdue.length})',
              icon: const Icon(Icons.warning_amber_rounded, size: 18),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Vaccine'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _VaccineList(
                  records: _all,
                  emptyMessage: 'No vaccinations recorded yet.\nTap + to add.',
                  emptyIcon: Icons.vaccines_rounded,
                  onEdit: _showAddSheet,
                  onDelete: _delete,
                ),
                _VaccineList(
                  records: _upcoming,
                  emptyMessage: 'No upcoming vaccinations\nin the next 60 days.',
                  emptyIcon: Icons.check_circle_rounded,
                  color: const Color(0xFF2563EB),
                  onEdit: _showAddSheet,
                  onDelete: _delete,
                ),
                _VaccineList(
                  records: _overdue,
                  emptyMessage: 'No overdue vaccinations.\nGreat job!',
                  emptyIcon: Icons.check_circle_rounded,
                  color: const Color(0xFFEF4444),
                  onEdit: _showAddSheet,
                  onDelete: _delete,
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// List widget
// ---------------------------------------------------------------------------

class _VaccineList extends StatelessWidget {
  final List<VaccinationRecord> records;
  final String emptyMessage;
  final IconData emptyIcon;
  final Color color;
  final void Function({VaccinationRecord? existing}) onEdit;
  final Future<void> Function(VaccinationRecord) onDelete;

  const _VaccineList({
    required this.records,
    required this.emptyMessage,
    required this.emptyIcon,
    this.color = const Color(0xFF10B981),
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _VaccineTile(
        record: records[i],
        accentColor: color,
        onEdit: () => onEdit(existing: records[i]),
        onDelete: () => onDelete(records[i]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tile widget
// ---------------------------------------------------------------------------

class _VaccineTile extends StatelessWidget {
  final VaccinationRecord record;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VaccineTile({
    required this.record,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final overdue = record.nextDueDate != null &&
        record.nextDueDate!.isBefore(DateTime.now());
    final soon = record.nextDueDate != null &&
        !overdue &&
        record.nextDueDate!
            .isBefore(DateTime.now().add(const Duration(days: 14)));

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: overdue
                  ? const Color(0xFFEF4444).withOpacity(0.4)
                  : soon
                  ? const Color(0xFFF59E0B).withOpacity(0.4)
                  : Colors.grey.shade100,
            ),
          ),
          child: Row(
            children: [
              // Vaccine icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vaccines_rounded,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.vaccineName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (overdue)
                          _StatusBadge('Overdue', const Color(0xFFEF4444)),
                        if (soon && !overdue)
                          _StatusBadge('Due Soon', const Color(0xFFF59E0B)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.memberName}  •  Dose ${record.doseNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 13,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Given: ${fmt.format(record.dateGiven)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                        if (record.nextDueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: overdue
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${fmt.format(record.nextDueDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: overdue
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF475569),
                              fontWeight: overdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (record.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.notes,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Delete
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFCBD5E1),
                ),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit form sheet
// ---------------------------------------------------------------------------

class _VaccineFormSheet extends StatefulWidget {
  final VaccinationRecord? existing;
  final List<FamilyMember> members;
  final Future<void> Function(VaccinationRecord) onSaved;

  const _VaccineFormSheet({
    this.existing,
    required this.members,
    required this.onSaved,
  });

  @override
  State<_VaccineFormSheet> createState() => _VaccineFormSheetState();
}

class _VaccineFormSheetState extends State<_VaccineFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vaccineCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _doseCtrl;
  DateTime _dateGiven = DateTime.now();
  DateTime? _nextDueDate;
  FamilyMember? _selectedMember;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _vaccineCtrl = TextEditingController(text: e?.vaccineName ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _doseCtrl = TextEditingController(text: (e?.doseNumber ?? 1).toString());
    _dateGiven = e?.dateGiven ?? DateTime.now();
    _nextDueDate = e?.nextDueDate;
    if (e != null) {
      try {
        _selectedMember = widget.members.firstWhere((m) => m.id == e.memberId);
      } catch (_) {}
    }
    if (_selectedMember == null && widget.members.isNotEmpty) {
      _selectedMember = widget.members.first;
    }
  }

  @override
  void dispose() {
    _vaccineCtrl.dispose();
    _notesCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isGiven) async {
    final initial = isGiven ? _dateGiven : (_nextDueDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        if (isGiven) {
          _dateGiven = picked;
        } else {
          _nextDueDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a family member')),
      );
      return;
    }
    setState(() => _saving = true);
    final id = widget.existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final record = VaccinationRecord(
      id: id,
      memberId: _selectedMember!.id,
      memberName: _selectedMember!.name,
      vaccineName: _vaccineCtrl.text.trim(),
      doseNumber: int.tryParse(_doseCtrl.text.trim()) ?? 1,
      dateGiven: _dateGiven,
      nextDueDate: _nextDueDate,
      notes: _notesCtrl.text.trim(),
    );
    await widget.onSaved(record);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    widget.existing == null
                        ? 'Add Vaccination'
                        : 'Edit Vaccination',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Member picker
                      if (widget.members.isNotEmpty) ...[
                        const _Label('Family Member'),
                        DropdownButtonFormField<FamilyMember>(
                          value: _selectedMember,
                          decoration: _inputDecoration('Select member'),
                          items: widget.members
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedMember = v),
                          validator: (v) =>
                              v == null ? 'Please select a member' : null,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Vaccine name with autocomplete
                      const _Label('Vaccine Name'),
                      Autocomplete<String>(
                        initialValue:
                            TextEditingValue(text: _vaccineCtrl.text),
                        optionsBuilder: (value) {
                          if (value.text.isEmpty) return _kVaccineSuggestions;
                          return _kVaccineSuggestions.where(
                            (s) => s.toLowerCase().contains(
                              value.text.toLowerCase(),
                            ),
                          );
                        },
                        onSelected: (s) => _vaccineCtrl.text = s,
                        fieldViewBuilder: (
                          context,
                          ctrl,
                          focusNode,
                          onSubmit,
                        ) {
                          // Sync the external controller
                          ctrl.text = _vaccineCtrl.text;
                          ctrl.addListener(() => _vaccineCtrl.text = ctrl.text);
                          return TextFormField(
                            controller: ctrl,
                            focusNode: focusNode,
                            decoration:
                                _inputDecoration('e.g. BCG, Hepatitis B…'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Enter vaccine name'
                                    : null,
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Dose number
                      const _Label('Dose Number'),
                      TextFormField(
                        controller: _doseCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('1'),
                      ),
                      const SizedBox(height: 14),

                      // Date given
                      const _Label('Date Given'),
                      _DateTile(
                        label: fmt.format(_dateGiven),
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () => _pickDate(true),
                      ),
                      const SizedBox(height: 14),

                      // Next due date (optional)
                      const _Label('Next Due Date (optional)'),
                      _DateTile(
                        label: _nextDueDate != null
                            ? fmt.format(_nextDueDate!)
                            : 'Not set — tap to set',
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFF2563EB),
                        onTap: () => _pickDate(false),
                        trailing: _nextDueDate != null
                            ? GestureDetector(
                                onTap: () =>
                                    setState(() => _nextDueDate = null),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF94A3B8),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Notes
                      const _Label('Notes (optional)'),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 2,
                        decoration: _inputDecoration(
                          'e.g. clinic name, batch number…',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Record',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF10B981)),
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DateTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: label.startsWith('Not set')
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            trailing ?? const Icon(Icons.edit_calendar_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
