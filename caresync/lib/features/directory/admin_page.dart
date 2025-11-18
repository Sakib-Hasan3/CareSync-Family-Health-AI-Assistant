import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'bd_data.dart';
import 'repositories.dart';

class DirectoryAdminPage extends StatefulWidget {
  const DirectoryAdminPage({super.key});

  @override
  State<DirectoryAdminPage> createState() => _DirectoryAdminPageState();
}

class _DirectoryAdminPageState extends State<DirectoryAdminPage> {
  final _repo = DirectoryRepository(db: FirebaseFirestore.instance);

  bool _seeding = false;
  String? _seedLog;

  Division? _division;
  District? _district;
  final _centerNameCtrl = TextEditingController();
  final _centerAddrCtrl = TextEditingController();
  final _centerPhoneCtrl = TextEditingController();
  final _centerEmailCtrl = TextEditingController();

  MedicalCenter? _center;
  final _doctorNameCtrl = TextEditingController();
  final _doctorSpecCtrl = TextEditingController();
  final _doctorPhoneCtrl = TextEditingController();
  final _doctorEmailCtrl = TextEditingController();

  List<Division> _divisions = [];
  List<District> _districts = [];
  List<MedicalCenter> _centers = [];
  List<DoctorProfile> _doctors = [];

  // Schedule editor state
  DoctorProfile? _selectedDoctor;
  int _weekday = 1; // 1=Mon..7=Sun
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<DutySlot> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadDivisions();
  }

  Future<void> _loadDivisions() async {
    final ds = await _repo.listDivisions();
    setState(() => _divisions = ds);
  }

  Future<void> _seedBangladesh() async {
    setState(() {
      _seeding = true;
      _seedLog = 'Starting seed...';
    });
    try {
      // Map division name => id
      final Map<String, String> divIds = {};
      // Ensure divisions exist
      for (final name in bdDivisions) {
        // Check existing
        final existing = _divisions.firstWhere(
          (d) => d.name.toLowerCase() == name.toLowerCase(),
          orElse: () => Division(id: '', name: ''),
        );
        String id;
        if (existing.id.isNotEmpty) {
          id = existing.id;
        } else {
          id = await _repo.createDivision(name);
        }
        divIds[name] = id;
      }
      _seedLog = 'Divisions ready. Creating districts...';
      setState(() {});

      // Create districts
      for (final entry in bdDistrictsByDivision.entries) {
        final divName = entry.key;
        final divisionId = divIds[divName]!;
        final existing = await _repo.listDistricts(divisionId);
        final existingSet = existing.map((e) => e.name.toLowerCase()).toSet();
        for (final distName in entry.value) {
          if (!existingSet.contains(distName.toLowerCase())) {
            await _repo.createDistrict(divisionId: divisionId, name: distName);
          }
        }
      }
      _seedLog = 'Seed completed.';
      await _loadDivisions();
    } catch (e) {
      _seedLog = 'Error: $e';
    } finally {
      setState(() {
        _seeding = false;
      });
    }
  }

  Future<void> _onDivisionChanged(Division? d) async {
    setState(() {
      _division = d;
      _district = null;
      _center = null;
      _districts = [];
      _centers = [];
    });
    if (d != null) {
      final list = await _repo.listDistricts(d.id);
      setState(() => _districts = list);
    }
  }

  Future<void> _onDistrictChanged(District? dist) async {
    setState(() {
      _district = dist;
      _center = null;
      _centers = [];
      _doctors = [];
      _selectedDoctor = null;
      _slots = [];
    });
    if (_division != null && dist != null) {
      final list = await _repo.listCenters(_division!.id, dist.id);
      setState(() => _centers = list);
    }
  }

  Future<void> _createCenter() async {
    if (_division == null || _district == null) return;
    final name = _centerNameCtrl.text.trim();
    if (name.isEmpty) return;
    final id = await _repo.createCenter(
      divisionId: _division!.id,
      districtId: _district!.id,
      name: name,
      address: _centerAddrCtrl.text.trim(),
      phone: _centerPhoneCtrl.text.trim().isEmpty
          ? null
          : _centerPhoneCtrl.text.trim(),
      email: _centerEmailCtrl.text.trim().isEmpty
          ? null
          : _centerEmailCtrl.text.trim(),
    );
    _centerNameCtrl.clear();
    _centerAddrCtrl.clear();
    _centerPhoneCtrl.clear();
    _centerEmailCtrl.clear();
    // refresh centers
    final list = await _repo.listCenters(_division!.id, _district!.id);
    setState(() => _centers = list);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Center created ($id)')));
  }

  Future<void> _createDoctor() async {
    if (_center == null) return;
    final name = _doctorNameCtrl.text.trim();
    final spec = _doctorSpecCtrl.text.trim();
    if (name.isEmpty || spec.isEmpty) return;
    final id = await _repo.createDoctor(
      centerId: _center!.id,
      fullName: name,
      specialization: spec,
      phone: _doctorPhoneCtrl.text.trim().isEmpty
          ? null
          : _doctorPhoneCtrl.text.trim(),
      email: _doctorEmailCtrl.text.trim().isEmpty
          ? null
          : _doctorEmailCtrl.text.trim(),
    );
    _doctorNameCtrl.clear();
    _doctorSpecCtrl.clear();
    _doctorPhoneCtrl.clear();
    _doctorEmailCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Doctor created ($id)')));
  }

  Future<void> _setSimpleSchedule() async {
    // Simple: Mon-Fri 09:00-17:00 for selected center's first doctor chosen via dialog
    if (_center == null) return;
    final doctors = await _repo.listDoctorsByCenter(_center!.id);
    if (doctors.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No doctors in this center')),
      );
      return;
    }
    final doctor = await showDialog<DoctorProfile>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select doctor'),
        children: doctors
            .map(
              (d) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, d),
                child: Text('${d.fullName} • ${d.specialization}'),
              ),
            )
            .toList(),
      ),
    );
    if (doctor == null) return;
    final slots = [
      for (int wd = 1; wd <= 5; wd++)
        DutySlot(weekday: wd, start: '09:00', end: '17:00'),
    ];
    await _repo.setSchedule(doctorId: doctor.id, slots: slots);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Schedule saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Directory Admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _seeding ? null : _seedBangladesh,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Seed Bangladesh Divisions & Districts'),
                ),
                const SizedBox(width: 12),
                if (_seeding) const CircularProgressIndicator(),
              ],
            ),
            if (_seedLog != null) ...[
              const SizedBox(height: 8),
              Text(_seedLog!),
            ],
            const Divider(height: 32),

            const Text(
              'Create Medical Center',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Division>(
              value: _division,
              decoration: const InputDecoration(labelText: 'Division'),
              items: _divisions
                  .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                  .toList(),
              onChanged: _onDivisionChanged,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<District>(
              value: _district,
              decoration: const InputDecoration(labelText: 'District'),
              items: _districts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                  .toList(),
              onChanged: _onDistrictChanged,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _centerNameCtrl,
              decoration: const InputDecoration(labelText: 'Center name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _centerAddrCtrl,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _centerPhoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _centerEmailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: (_division != null && _district != null)
                    ? _createCenter
                    : null,
                child: const Text('Create Center'),
              ),
            ),

            const Divider(height: 32),

            const Text(
              'Add Doctor to Center',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MedicalCenter>(
              value: _center,
              decoration: const InputDecoration(labelText: 'Medical Center'),
              items: _centers
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (c) async {
                setState(() {
                  _center = c;
                  _doctors = [];
                  _selectedDoctor = null;
                  _slots = [];
                });
                if (c != null) {
                  final docs = await _repo.listDoctorsByCenter(c.id);
                  setState(() => _doctors = docs);
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _doctorNameCtrl,
              decoration: const InputDecoration(labelText: 'Doctor full name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _doctorSpecCtrl,
              decoration: const InputDecoration(labelText: 'Specialization'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _doctorPhoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _doctorEmailCtrl,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _center != null ? _createDoctor : null,
                  child: const Text('Add Doctor'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _center != null ? _setSimpleSchedule : null,
                  child: const Text('Set 9-5 Mon-Fri Schedule'),
                ),
              ],
            ),

            const Divider(height: 32),

            const Text(
              'Doctor Schedule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<DoctorProfile>(
              value: _selectedDoctor,
              decoration: const InputDecoration(labelText: 'Doctor'),
              items: _doctors
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text('${d.fullName} • ${d.specialization}'),
                    ),
                  )
                  .toList(),
              onChanged: (d) async {
                setState(() {
                  _selectedDoctor = d;
                  _slots = [];
                });
                if (d != null) {
                  final sch = await _repo.getSchedule(d.id);
                  setState(() => _slots = sch?.slots ?? []);
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _weekday,
                    decoration: const InputDecoration(labelText: 'Weekday'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Monday')),
                      DropdownMenuItem(value: 2, child: Text('Tuesday')),
                      DropdownMenuItem(value: 3, child: Text('Wednesday')),
                      DropdownMenuItem(value: 4, child: Text('Thursday')),
                      DropdownMenuItem(value: 5, child: Text('Friday')),
                      DropdownMenuItem(value: 6, child: Text('Saturday')),
                      DropdownMenuItem(value: 7, child: Text('Sunday')),
                    ],
                    onChanged: (v) => setState(() => _weekday = v ?? 1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStartTime,
                    child: Text(
                      _startTime == null ? 'Start time' : _fmtTime(_startTime!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEndTime,
                    child: Text(
                      _endTime == null ? 'End time' : _fmtTime(_endTime!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedDoctor == null ? null : _addSlot,
                  child: const Text('Add Slot'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_slots.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _slots
                        .asMap()
                        .entries
                        .map(
                          (e) => Chip(
                            label: Text(_slotLabel(e.value)),
                            onDeleted: () {
                              setState(() => _slots.removeAt(e.key));
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: _selectedDoctor == null ? null : _saveSchedule,
                      child: const Text('Save Schedule'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h % 12 == 0 ? 12 : h % 12;
    return '$dh:${m.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _startTime = t);
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _endTime = t);
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

  void _addSlot() {
    if (_selectedDoctor == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select weekday, start and end time')),
      );
      return;
    }
    final startMin = _startTime!.hour * 60 + _startTime!.minute;
    final endMin = _endTime!.hour * 60 + _endTime!.minute;
    if (endMin <= startMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    setState(() {
      _slots.add(
        DutySlot(
          weekday: _weekday,
          start:
              '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
          end:
              '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        ),
      );
      _startTime = null;
      _endTime = null;
    });
  }

  Future<void> _saveSchedule() async {
    if (_selectedDoctor == null || _slots.isEmpty) return;
    await _repo.setSchedule(doctorId: _selectedDoctor!.id, slots: _slots);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Schedule saved')));
  }
}
