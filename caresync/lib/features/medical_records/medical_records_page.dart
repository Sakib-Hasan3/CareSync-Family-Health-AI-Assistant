import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'models/medical_record.dart';
import 'models.dart';
import 'medical_record_repository.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  final MedicalRecordRepository _repo = MedicalRecordRepository();
  List<MedicalRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _repo.init();
    final r = _repo.getAll();
    setState(() {
      _records = r;
      _loading = false;
    });
  }

  Future<void> _addRecord() async {
    final result = await showModalBottomSheet<MedicalRecord>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddRecordSheet(),
    );
    if (result != null) {
      final srcPath = result.location;
      if (srcPath.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please attach a file')));
        return;
      }
      // Default category mapping: use labReport when mapping is unknown
      await _repo.addFromPath(
        srcPath: srcPath,
        name: result.title,
        category: RecordCategory.labReport,
        mimeType: null,
      );
      await _load();
    }
  }

  Future<void> _delete(String id) async {
    final rec = _records.firstWhere((r) => r.id == id);
    await _repo.delete(rec);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Records')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, i) {
                final rec = _records[i];
                return Card(
                  child: ListTile(
                    title: Text(rec.title),
                    subtitle: Text(
                      '${rec.type} • ${rec.date.toLocal().toIso8601String().split('T').first}${rec.attachmentName != null ? ' • ${rec.attachmentName}' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _delete(rec.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AddRecordSheet extends StatefulWidget {
  const _AddRecordSheet({Key? key}) : super(key: key);

  @override
  State<_AddRecordSheet> createState() => __AddRecordSheetState();
}

class __AddRecordSheetState extends State<_AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  String _type = 'lab';
  DateTime _date = DateTime.now();
  String? _attachmentName;
  Uint8List? _attachmentData;
  String _localPath = '';

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final rec = MedicalRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      type: _type,
      date: _date,
      notes: '',
      location: _localPath,
      attachmentName: _attachmentName,
      attachmentData: _attachmentData,
    );
    Navigator.of(context).pop(rec);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _type,
                    items: const [
                      DropdownMenuItem(value: 'lab', child: Text('Lab Report')),
                      DropdownMenuItem(
                        value: 'prescription',
                        child: Text('Prescription'),
                      ),
                      DropdownMenuItem(
                        value: 'vaccination',
                        child: Text('Vaccination'),
                      ),
                      DropdownMenuItem(value: 'scan', child: Text('Scan')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'lab'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Date: ${_date.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) setState(() => _date = d);
                        },
                        child: const Text('Pick'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _attachmentName ?? 'No attachment selected',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            withData: true,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.first;
                            _attachmentName = file.name;
                            _attachmentData = file.bytes;
                            _localPath = file.path ?? '';
                            setState(() {});
                          }
                        },
                        child: const Text('Attach'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
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
}
