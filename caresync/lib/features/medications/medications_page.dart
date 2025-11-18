import 'package:flutter/material.dart';
import 'package:caresync/features/health_timeline/iconsax_stub.dart';
import 'models/medication.dart';
import 'medication_repository.dart';
import 'medication_reminder_service.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final _repo = MedicationRepository();
  final _reminders = MedicationReminderService();
  bool _loading = true;
  List<Medication> _meds = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.init();
    await _reminders.initialize();
    _refresh();
  }

  void _refresh() {
    final list = _repo.getAll()..sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _meds = list;
      _loading = false;
    });
  }

  Future<void> _addMedication() async {
    final med = await showModalBottomSheet<Medication>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MedicationFormSheet(),
    );
    if (med != null) {
      await _repo.addOrUpdate(med);
      if (med.nextDose != null) {
        await _reminders.scheduleDoseReminder(med, med.nextDose!);
        // Optional: trigger SMS via your backend if integrated
        // await _sendSmsReminder(med);
      }
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Medication saved')));
    }
  }

  Future<void> _deleteMedication(Medication m) async {
    await _repo.delete(m.id);
    await _reminders.cancelReminder(m.id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.eye),
            tooltip: 'Test notification',
            onPressed: () => _reminders.showTest(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _meds.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _meds.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _MedicationTile(
                  med: _meds[i],
                  onDelete: () => _deleteMedication(_meds[i]),
                  onSchedule: () async {
                    final m = _meds[i];
                    if (m.nextDose != null) {
                      await _reminders.scheduleDoseReminder(m, m.nextDose!);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder scheduled')),
                      );
                    }
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMedication,
        icon: const Icon(Iconsax.health, color: Colors.white),
        label: const Text('Add Medication'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.health, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Medications Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your medications to get reminders and tips.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  final Medication med;
  final VoidCallback onDelete;
  final VoidCallback onSchedule;

  const _MedicationTile({
    required this.med,
    required this.onDelete,
    required this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.health, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${med.dosage} • ${med.frequency}${med.time.isNotEmpty ? ' • ${med.time}' : ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  if (med.nextDose != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock_1,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(med.nextDose!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: onSchedule,
                  icon: const Icon(
                    Iconsax.calendar_tick,
                    color: Color(0xFF2563EB),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Iconsax.trash, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime d) {
    final hour = d.hour;
    final minute = d.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final time = '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    return '${d.day}/${d.month}/${d.year} • $time';
  }
}

class _MedicationFormSheet extends StatefulWidget {
  const _MedicationFormSheet();

  @override
  State<_MedicationFormSheet> createState() => _MedicationFormSheetState();
}

class _MedicationFormSheetState extends State<_MedicationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _freqCtrl = TextEditingController(text: 'Once daily');
  DateTime? _date;
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 12),
              const Text(
                'Add Medication',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Medication name',
                        prefixIcon: Icon(Iconsax.health),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dosageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dosage (e.g. 100 mg)',
                        prefixIcon: Icon(Icons.science_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _freqCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        prefixIcon: Icon(Icons.repeat),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _date == null
                                  ? 'Select date'
                                  : '${_date!.day}/${_date!.month}/${_date!.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Iconsax.clock_1),
                            label: Text(
                              _time == null
                                  ? 'Select time'
                                  : _formatTime(_time!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Iconsax.health),
                        label: const Text('Save Medication'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _time = t);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    DateTime? next;
    String timeLabel = '';
    if (_date != null && _time != null) {
      next = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time!.hour,
        _time!.minute,
      );
      final h = _time!.hour;
      final m = _time!.minute;
      final period = h >= 12 ? 'PM' : 'AM';
      final dh = h % 12 == 0 ? 12 : h % 12;
      timeLabel = '$dh:${m.toString().padLeft(2, '0')} $period';
    }
    final med = Medication(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _freqCtrl.text.trim(),
      nextDose: next,
      time: timeLabel,
    );
    Navigator.of(context).pop(med);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h % 12 == 0 ? 12 : h % 12;
    return '$dh:${m.toString().padLeft(2, '0')} $period';
  }
}
