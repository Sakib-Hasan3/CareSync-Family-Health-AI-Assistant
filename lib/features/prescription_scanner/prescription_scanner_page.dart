import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:caresync/features/ai_assistant/ai_service.dart';
import 'package:caresync/features/medications/medication_repository.dart';
import 'package:caresync/features/medications/models/medication.dart';

class PrescriptionScannerPage extends StatefulWidget {
  const PrescriptionScannerPage({super.key});

  @override
  State<PrescriptionScannerPage> createState() =>
      _PrescriptionScannerPageState();
}

class _PrescriptionScannerPageState extends State<PrescriptionScannerPage> {
  final _picker = ImagePicker();
  final _ai = AIService();

  Uint8List? _imageBytes;
  String? _imageMime;
  bool _scanning = false;
  PrescriptionResult? _result;
  String? _error;

  // -------------------------------------------------------------------------
  // Image picking
  // -------------------------------------------------------------------------
  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final mime = file.mimeType ?? 'image/jpeg';
    setState(() {
      _imageBytes = bytes;
      _imageMime = mime;
      _result = null;
      _error = null;
    });
  }

  // -------------------------------------------------------------------------
  // Scan via AI
  // -------------------------------------------------------------------------
  Future<void> _scan() async {
    if (_imageBytes == null) return;
    setState(() {
      _scanning = true;
      _error = null;
      _result = null;
    });

    const systemPrompt = '''
You are a medical prescription OCR and analysis assistant.
Carefully read the prescription image and respond ONLY with a structured text in exactly this format (fill in what you can see; write "Not found" for missing fields):

PATIENT: <patient name>
DOCTOR: <doctor name and/or hospital>
DATE: <prescription date>
DIAGNOSIS: <diagnosis or condition if visible>
MEDICATIONS:
- <drug name> | <dosage> | <frequency> | <duration> | <instructions>
- <drug name> | <dosage> | <frequency> | <duration> | <instructions>
NOTES: <any additional notes>

Do NOT add any commentary outside this format.
''';

    try {
      final hasKey = await AIService.hasAnyApiKey();
      String raw;

      if (hasKey) {
        // Vision-capable path: send raw image to Gemini / proxy
        raw = await _ai.askWithImage(
          _imageBytes!,
          mimeType: _imageMime,
          prompt: systemPrompt,
        );
      } else {
        throw StateError('NO_API_K');
      }

      final parsed = PrescriptionResult.parse(raw);
      setState(() {
        _result = parsed;
        _scanning = false;
      });
    } on StateError catch (e) {
      final msg = e.message;
      setState(() {
        _scanning = false;
        _error = msg.startsWith('NO_API_K')
            ? 'No AI key configured. Go to AI Settings and paste your OpenRouter key, then try again.'
            : 'Could not read prescription: $msg';
      });
    } catch (e) {
      setState(() {
        _scanning = false;
        _error = 'Unexpected error: $e';
      });
    }
  }

  // -------------------------------------------------------------------------
  // Save a medication from the result
  // -------------------------------------------------------------------------
  Future<void> _addMedication(ParsedMedication med) async {
    final repo = MedicationRepository();
    await repo.init();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final m = Medication(
      id: id,
      name: med.name,
      dosage: med.dosage,
      frequency: med.frequency,
      remaining: 30,
      time: '',
    );
    await repo.addOrUpdate(m);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${med.name} added to your medications'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Prescription Scanner',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info banner
            _InfoBanner(),
            const SizedBox(height: 16),

            // Image preview
            _ImagePreview(
              bytes: _imageBytes,
              onPickCamera: () => _pick(ImageSource.camera),
              onPickGallery: () => _pick(ImageSource.gallery),
            ),
            const SizedBox(height: 16),

            // Scan button
            if (_imageBytes != null)
              ElevatedButton.icon(
                onPressed: _scanning ? null : _scan,
                icon: _scanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.document_scanner_rounded),
                label: Text(_scanning ? 'Scanning…' : 'Scan Prescription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 16),
              _ErrorCard(message: _error!),
            ],

            // Results
            if (_result != null) ...[
              const SizedBox(height: 20),
              _ResultCard(result: _result!, onAddMed: _addMedication),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Data models
// =============================================================================

class ParsedMedication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  const ParsedMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.duration = '',
    this.instructions = '',
  });

  factory ParsedMedication.fromLine(String line) {
    final parts = line.split('|').map((s) => s.trim()).toList();
    return ParsedMedication(
      name: parts.isNotEmpty ? parts[0] : 'Unknown',
      dosage: parts.length > 1 ? parts[1] : '',
      frequency: parts.length > 2 ? parts[2] : '',
      duration: parts.length > 3 ? parts[3] : '',
      instructions: parts.length > 4 ? parts[4] : '',
    );
  }
}

class PrescriptionResult {
  final String patient;
  final String doctor;
  final String date;
  final String diagnosis;
  final List<ParsedMedication> medications;
  final String notes;
  final String rawText;

  const PrescriptionResult({
    required this.patient,
    required this.doctor,
    required this.date,
    required this.diagnosis,
    required this.medications,
    required this.notes,
    required this.rawText,
  });

  factory PrescriptionResult.parse(String raw) {
    String _field(String key) {
      final pattern = RegExp('^$key:\\s*(.+)', multiLine: true, caseSensitive: false);
      final m = pattern.firstMatch(raw);
      return m?.group(1)?.trim() ?? 'Not found';
    }

    final medLines = <String>[];
    bool inMeds = false;
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.toUpperCase().startsWith('MEDICATIONS:')) {
        inMeds = true;
        continue;
      }
      if (inMeds) {
        if (trimmed.startsWith('-')) {
          medLines.add(trimmed.substring(1).trim());
        } else if (trimmed.isNotEmpty &&
            !trimmed.startsWith('#') &&
            !trimmed.startsWith('NOTES:')) {
          // continuation line
        } else {
          inMeds = false;
        }
      }
    }

    return PrescriptionResult(
      patient: _field('PATIENT'),
      doctor: _field('DOCTOR'),
      date: _field('DATE'),
      diagnosis: _field('DIAGNOSIS'),
      medications: medLines
          .where((l) => l.isNotEmpty)
          .map(ParsedMedication.fromLine)
          .toList(),
      notes: _field('NOTES'),
      rawText: raw,
    );
  }
}

// =============================================================================
// Widgets
// =============================================================================

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Take a clear photo of a prescription. AI will extract medication details so you can add them to your list.',
              style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Uint8List? bytes;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;

  const _ImagePreview({
    required this.bytes,
    required this.onPickCamera,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: bytes != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(bytes!, fit: BoxFit.contain),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PickButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: onPickCamera,
                      ),
                      const SizedBox(width: 8),
                      _PickButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: onPickGallery,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 48,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select a prescription image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Take a clear photo or pick from gallery',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PickButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: onPickCamera,
                    ),
                    const SizedBox(width: 12),
                    _PickButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: onPickGallery,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final PrescriptionResult result;
  final Future<void> Function(ParsedMedication) onAddMed;

  const _ResultCard({required this.result, required this.onAddMed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Prescription Extracted',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Patient info card
        _InfoCard(
          title: 'Patient Information',
          icon: Icons.person_outline_rounded,
          color: const Color(0xFF2563EB),
          children: [
            _InfoRow('Patient', result.patient),
            _InfoRow('Doctor / Hospital', result.doctor),
            _InfoRow('Date', result.date),
            if (result.diagnosis != 'Not found')
              _InfoRow('Diagnosis', result.diagnosis),
          ],
        ),
        const SizedBox(height: 12),

        // Medications
        if (result.medications.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Medications',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${result.medications.length} found',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...result.medications.map(
                  (med) => _MedTile(med: med, onAdd: () => onAddMed(med)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Notes
        if (result.notes != 'Not found') ...[
          _InfoCard(
            title: 'Additional Notes',
            icon: Icons.notes_rounded,
            color: const Color(0xFFF59E0B),
            children: [
              Text(
                result.notes,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI-extracted data may contain errors. Always verify with the original prescription and your healthcare provider.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedTile extends StatefulWidget {
  final ParsedMedication med;
  final VoidCallback onAdd;

  const _MedTile({required this.med, required this.onAdd});

  @override
  State<_MedTile> createState() => _MedTileState();
}

class _MedTileState extends State<_MedTile> {
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            size: 8,
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.med.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                if (widget.med.dosage.isNotEmpty)
                  _Chip('Dosage: ${widget.med.dosage}'),
                if (widget.med.frequency.isNotEmpty)
                  _Chip('Frequency: ${widget.med.frequency}'),
                if (widget.med.duration.isNotEmpty)
                  _Chip('Duration: ${widget.med.duration}'),
                if (widget.med.instructions.isNotEmpty &&
                    widget.med.instructions.toLowerCase() != 'not found')
                  _Chip(widget.med.instructions),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _added
                ? null
                : () async {
                    widget.onAdd();
                    if (mounted) setState(() => _added = true);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _added
                    ? const Color(0xFF10B981)
                    : const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _added ? 'Added ✓' : '+ Add',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
      ),
    );
  }
}
