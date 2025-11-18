import 'package:flutter/material.dart';
import '../request_repository.dart';
import '../models/blood_request.dart';
import '../donor_match_service.dart';

class BloodRequestPage extends StatefulWidget {
  const BloodRequestPage({super.key});

  @override
  State<BloodRequestPage> createState() => _BloodRequestPageState();
}

class _BloodRequestPageState extends State<BloodRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _cityCtl = TextEditingController();
  String _bloodGroup = 'O+';
  int _units = 1;
  String _urgency = 'high';
  final RequestRepository _repo = RequestRepository();

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _cityCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final r = BloodRequest(
      id: id,
      requesterName: _nameCtl.text.trim(),
      bloodGroupNeeded: _bloodGroup,
      units: _units,
      urgency: _urgency,
      locationCity: _cityCtl.text.trim(),
      contactPhone: _phoneCtl.text.trim(),
    );
    await _repo.init();
    await _repo.add(r);

    // find matches and show
    final matches = await DonorMatchService().findMatches(
      bloodGroup: _bloodGroup,
      city: _cityCtl.text.trim(),
    );
    if (mounted) {
      await showModalBottomSheet(
        context: context,
        builder: (c) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Found ${matches.length} matching donors',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...matches.map(
                (d) => ListTile(
                  title: Text(d.name),
                  subtitle: Text('${d.bloodGroup} • ${d.city} • ${d.phone}'),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Your name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                items: ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-']
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _bloodGroup = v ?? _bloodGroup),
                decoration: const InputDecoration(
                  labelText: 'Blood group needed',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtl,
                decoration: const InputDecoration(labelText: 'Contact phone'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtl,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter city' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Units:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _units,
                    items: [1, 2, 3, 4, 5]
                        .map(
                          (n) => DropdownMenuItem(value: n, child: Text('$n')),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _units = v ?? 1),
                  ),
                  const SizedBox(width: 20),
                  const Text('Urgency:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _urgency,
                    items: ['low', 'medium', 'high']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _urgency = v ?? 'high'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
