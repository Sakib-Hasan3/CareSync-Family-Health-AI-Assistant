import 'package:flutter/material.dart';
import 'package:caresync/features/health_timeline/iconsax_stub.dart';
import 'appointment_repository.dart';
import 'appointment_reminder_service.dart';
import 'appointment_pdf_service.dart';
import 'models/appointment.dart';
import 'ui/division_selection_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppointmentRepository _repo = AppointmentRepository();
  final AppointmentReminderService _reminders = AppointmentReminderService();
  final AppointmentPdfService _pdfs = AppointmentPdfService();
  bool _loading = true;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.init();
    await _reminders.initialize();
    _refreshList();
  }

  void _refreshList() {
    final items = _repo.getAll()
      ..sort((a, b) => a.datetime.compareTo(b.datetime));
    setState(() {
      _appointments = items;
      _loading = false;
    });
  }

  Future<void> _deleteAppointment(String id) async {
    await _repo.delete(id);
    await _reminders.cancelReminder(id);
    _refreshList();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment deleted')));
    }
  }

  Future<void> _toggleCompleted(Appointment ap) async {
    final updated = ap.copyWith(isCompleted: !ap.isCompleted);
    await _repo.addOrUpdate(updated);
    _refreshList();
  }

  Future<void> _bookAppointment() async {
    final created = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AppointmentFormSheet(),
    );
    if (created != null) {
      await _repo.addOrUpdate(created);
      if (created.reminderMinutesBefore > 0) {
        await _reminders.scheduleReminder(created);
      }
      _refreshList();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appointment booked')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _refreshList,
          ),
          IconButton(
            icon: const Icon(Iconsax.eye),
            tooltip: 'Test notification',
            onPressed: () => _reminders.showTestNotification(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async => _refreshList(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final ap = _appointments[index];
                  return _AppointmentTile(
                    appointment: ap,
                    onToggleComplete: () => _toggleCompleted(ap),
                    onDelete: () => _deleteAppointment(ap.id),
                    onReschedule: () async {
                      await _reminders.rescheduleReminder(ap);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder rescheduled')),
                        );
                      }
                    },
                    onSchedule: () async {
                      await _reminders.scheduleReminder(ap);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder scheduled')),
                        );
                      }
                    },
                    onCancelReminder: () async {
                      await _reminders.cancelReminder(ap.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder canceled')),
                        );
                      }
                    },
                    onSavePdf: () async {
                      final path = await _pdfs.savePdfWithPicker(ap);
                      if (!mounted) return;
                      if (path != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF saved to: $path')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Save canceled')),
                        );
                      }
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _appointments.length,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DivisionSelectionPage()),
        ),
        icon: const Icon(Icons.calendar_today, color: Colors.white),
        label: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              child: const Icon(Iconsax.calendar, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Appointments Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the button below to book your first appointment and get reminders',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onReschedule;
  final VoidCallback onSchedule;
  final VoidCallback onCancelReminder;
  final VoidCallback onSavePdf;

  const _AppointmentTile({
    required this.appointment,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onReschedule,
    required this.onSchedule,
    required this.onCancelReminder,
    required this.onSavePdf,
  });

  @override
  Widget build(BuildContext context) {
    final ap = appointment;
    final dateStr =
        '${ap.datetime.day}/${ap.datetime.month}/${ap.datetime.year}';
    final timeStr = _formatTime(ap.datetime);
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
                color: ap.isCompleted
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                ap.isCompleted ? Iconsax.tick_circle : Iconsax.calendar,
                color: ap.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ap.title.isNotEmpty ? ap.title : 'Appointment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ap.doctor}${ap.specialty != null && ap.specialty!.isNotEmpty ? ' • ${ap.specialty}' : ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
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
                        '$dateStr • $timeStr',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if ((ap.location).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ap.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ActionChip(
                        icon: Iconsax.tick,
                        label: ap.isCompleted ? 'Mark Pending' : 'Mark Done',
                        onTap: onToggleComplete,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Iconsax.calendar_tick,
                        label: 'Schedule',
                        onTap: onSchedule,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Iconsax.refresh,
                        label: 'Reschedule',
                        onTap: onReschedule,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Iconsax.document,
                        label: 'Save PDF',
                        onTap: onSavePdf,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Iconsax.trash,
                        label: 'Delete',
                        onTap: onDelete,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final hour = d.hour;
    final minute = d.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF2563EB);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: c, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentFormSheet extends StatefulWidget {
  const _AppointmentFormSheet();

  @override
  State<_AppointmentFormSheet> createState() => _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends State<_AppointmentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _familyMemberCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _reminderMinutes = 60;

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
                'Book Appointment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Iconsax.document),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a title'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _doctorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Doctor',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter doctor name'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _specialtyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Specialty (optional)',
                        prefixIcon: Icon(Icons.local_hospital_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.place_outlined),
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
                              _selectedDate == null
                                  ? 'Select date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Iconsax.clock_1),
                            label: Text(
                              _selectedTime == null
                                  ? 'Select time'
                                  : _formatTimeOfDay(_selectedTime!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesCtrl,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _familyMemberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Family Member ID (optional)',
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Reminder:'),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: _reminderMinutes,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('None')),
                            DropdownMenuItem(
                              value: 30,
                              child: Text('30 min before'),
                            ),
                            DropdownMenuItem(
                              value: 60,
                              child: Text('1 hour before'),
                            ),
                            DropdownMenuItem(
                              value: 1440,
                              child: Text('1 day before'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _reminderMinutes = v ?? 0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Iconsax.calendar_add),
                        label: const Text('Book Appointment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
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
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }
    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final ap = Appointment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      doctorName: _doctorCtrl.text.trim(),
      clinic: _locationCtrl.text.trim(),
      dateTime: dt,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      reminderMinutesBefore: _reminderMinutes,
      familyMemberId: _familyMemberCtrl.text.trim().isEmpty
          ? null
          : _familyMemberCtrl.text.trim(),
      specialty: _specialtyCtrl.text.trim().isEmpty
          ? null
          : _specialtyCtrl.text.trim(),
    );
    Navigator.of(context).pop(ap);
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hour;
    final minute = t.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
