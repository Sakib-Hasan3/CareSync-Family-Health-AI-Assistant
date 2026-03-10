import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../appointments/appointment_repository.dart';
import '../appointments/appointment_reminder_service.dart';
import '../appointments/models/appointment.dart';
import '../appointments/appointment_pdf_service.dart';
import '../appointments/appointments_page.dart';
import 'repositories.dart';
import 'bd_data.dart';

class BrowseAndBookPage extends StatefulWidget {
  const BrowseAndBookPage({super.key});

  @override
  State<BrowseAndBookPage> createState() => _BrowseAndBookPageState();
}

class _BrowseAndBookPageState extends State<BrowseAndBookPage> {
  final _repo = DirectoryRepository(db: FirebaseFirestore.instance);
  final _appointments = AppointmentRepository();
  final _reminders = AppointmentReminderService();
  final _pdfs = AppointmentPdfService();

  Division? _division;
  District? _district;
  MedicalCenter? _center;

  List<Division> _divisions = [];
  List<District> _districts = [];
  List<MedicalCenter> _centers = [];
  List<DoctorProfile> _doctors = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _appointments.init();
    await _reminders.initialize();
    final ds = await _repo.listDivisions();
    setState(() {
      _divisions = ds;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse & Book')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _divisions.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDivisions(),
                  const SizedBox(height: 12),
                  _buildDistricts(),
                  if (_division != null && _districts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _NoDataBanner(
                        message:
                            'No districts found for ${_division!.name}. You can quickly seed them.',
                        primaryLabel: 'Seed districts for this division',
                        onPrimary: () => _seedDistrictsForDivision(_division!),
                        secondaryLabel: 'Open Directory Admin',
                        onSecondary: () async {
                          await Navigator.pushNamed(
                            context,
                            '/directory/admin',
                          );
                          if (!mounted) return;
                          _init();
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  _buildCenters(),
                  if (_district != null && _centers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _NoDataBanner(
                        message:
                            'No medical centers found in ${_district!.name}. Create one from Admin.',
                        primaryLabel: 'Open Directory Admin',
                        onPrimary: () async {
                          await Navigator.pushNamed(
                            context,
                            '/directory/admin',
                          );
                          if (!mounted) return;
                          _init();
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildDoctors()),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No directory data found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Please seed Bangladesh divisions & districts, then create a medical center and at least one doctor from the Directory Admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/directory/admin');
                    if (!mounted) return;
                    _init(); // reload after returning
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Open Directory Admin'),
                ),
                OutlinedButton.icon(
                  onPressed: _init,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivisions() {
    return DropdownButtonFormField<Division>(
      value: _division,
      items: _divisions
          .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
          .toList(),
      onChanged: (d) async {
        setState(() {
          _division = d;
          _district = null;
          _center = null;
          _districts = [];
          _centers = [];
          _doctors = [];
        });
        if (d != null) {
          final list = await _repo.listDistricts(d.id);
          if (!mounted) return;
          setState(() {
            _districts = list;
          });
        }
      },
      decoration: const InputDecoration(labelText: 'Division'),
    );
  }

  Widget _buildDistricts() {
    return DropdownButtonFormField<District>(
      value: _district,
      items: _districts
          .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
          .toList(),
      onChanged: (d) async {
        setState(() {
          _district = d;
          _center = null;
          _centers = [];
          _doctors = [];
        });
        if (_division != null && d != null) {
          final list = await _repo.listCenters(_division!.id, d.id);
          if (!mounted) return;
          setState(() {
            _centers = list;
          });
        }
      },
      decoration: const InputDecoration(labelText: 'District'),
    );
  }

  Widget _buildCenters() {
    return DropdownButtonFormField<MedicalCenter>(
      value: _center,
      items: _centers
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      onChanged: (c) async {
        setState(() {
          _center = c;
          _doctors = [];
        });
        if (c != null) {
          final list = await _repo.listDoctorsByCenter(c.id);
          if (!mounted) return;
          setState(() {
            _doctors = list;
          });
        }
      },
      decoration: const InputDecoration(labelText: 'Medical Center'),
    );
  }

  Widget _buildDoctors() {
    if (_center == null) return const SizedBox.shrink();
    return ListView.separated(
      itemCount: _doctors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = _doctors[index];
        return FutureBuilder<DutySchedule?>(
          future: _repo.getSchedule(d.id),
          builder: (context, snap) {
            final schedule = snap.data;
            final onDuty = schedule == null
                ? false
                : DutyHelper.isOnDutyNow(schedule);
            final upcoming = schedule == null
                ? []
                : DutyHelper.upcomingSlots(schedule);
            return Card(
              child: ListTile(
                title: Text('${d.fullName} • ${d.specialization}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(onDuty ? 'On duty now' : 'Off duty'),
                    if (upcoming.isNotEmpty)
                      Text('Next: ${_slotLabel(upcoming.first)}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _openBookForm(d, schedule),
                  child: const Text('Book'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _slotLabel(DutySlot s) {
    const days = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return '${days[s.weekday]} ${s.start}-${s.end}';
  }

  Future<void> _openBookForm(DoctorProfile d, DutySchedule? schedule) async {
    final ap = await showDialog<Appointment>(
      context: context,
      builder: (_) => _BookDialog(doctor: d, center: _center!),
    );
    if (ap != null) {
      await _appointments.addOrUpdate(ap);
      if (ap.reminderMinutesBefore > 0) await _reminders.scheduleReminder(ap);
      // Generate and prompt to save the appointment PDF
      try {
        final savedPath = await _pdfs.savePdfWithPicker(ap);
        if (!mounted) return;
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Appointment PDF saved to: $savedPath')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('PDF save canceled')));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment booked')));
      // Navigate to Appointments page so the user can see it immediately
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentsPage()),
      );
    }
  }

  Future<void> _seedDistrictsForDivision(Division division) async {
    final names = bdDistrictsByDivision[division.name];
    if (names == null || names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No known districts for ${division.name}')),
      );
      return;
    }
    try {
      // Fetch existing to avoid duplicates
      final existing = await _repo.listDistricts(division.id);
      final existingSet = existing.map((e) => e.name.toLowerCase()).toSet();
      for (final n in names) {
        if (!existingSet.contains(n.toLowerCase())) {
          await _repo.createDistrict(divisionId: division.id, name: n);
        }
      }
      // Reload list
      final updated = await _repo.listDistricts(division.id);
      if (!mounted) return;
      setState(() => _districts = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seeded districts for ${division.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to seed: $e')));
    }
  }
}

class _NoDataBanner extends StatelessWidget {
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _NoDataBanner({
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(onPressed: onPrimary, child: Text(primaryLabel)),
              if (secondaryLabel != null && onSecondary != null)
                OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookDialog extends StatefulWidget {
  final DoctorProfile doctor;
  final MedicalCenter center;
  const _BookDialog({required this.doctor, required this.center});

  @override
  State<_BookDialog> createState() => _BookDialogState();
}

class _BookDialogState extends State<_BookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  DateTime? _dob;
  String _gender = 'Male';
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  int _reminder = 60;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Book Appointment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Doctor: ${widget.doctor.fullName} (${widget.doctor.specialization})',
              ),
              Text('Center: ${widget.center.name}'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dobCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date of birth',
                      ),
                      onTap: _pickDob,
                      validator: (_) => _dob == null ? 'Select DOB' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Contact number'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nidCtrl,
                decoration: const InputDecoration(
                  labelText: 'National/Patient ID (optional)',
                ),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(
                        _date == null
                            ? 'Select date'
                            : '${_date!.day}/${_date!.month}/${_date!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      child: Text(
                        _time == null ? 'Select time' : _fmtTime(_time!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Reminder'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _reminder,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('None')),
                      DropdownMenuItem(value: 30, child: Text('30 min before')),
                      DropdownMenuItem(value: 60, child: Text('1 hour before')),
                      DropdownMenuItem(
                        value: 1440,
                        child: Text('1 day before'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _reminder = v ?? 0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Book')),
      ],
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (d != null)
      setState(() {
        _dob = d;
        _dobCtrl.text = '${d.day}/${d.month}/${d.year}';
      });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
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

  String _fmtTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h % 12 == 0 ? 12 : h % 12;
    return '$dh:${m.toString().padLeft(2, '0')} $period';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null || _date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }
    final dt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final appointment = Appointment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Appointment with ${widget.doctor.fullName}',
      doctorName: widget.doctor.fullName,
      clinic: widget.center.name,
      dateTime: dt,
      reminderMinutesBefore: _reminder,
      specialty: widget.doctor.specialization,
      patientName: _nameCtrl.text.trim(),
      patientDob: _dob,
      patientGender: _gender,
      patientPhone: _phoneCtrl.text.trim(),
      patientEmail: _emailCtrl.text.trim().isEmpty
          ? null
          : _emailCtrl.text.trim(),
      patientNationalId: _nidCtrl.text.trim().isEmpty
          ? null
          : _nidCtrl.text.trim(),
      centerId: widget.center.id,
      centerName: widget.center.name,
      centerContactPhone: widget.center.phone,
      centerContactEmail: widget.center.email,
      doctorId: widget.doctor.id,
    );
    Navigator.pop(context, appointment);
  }
}
