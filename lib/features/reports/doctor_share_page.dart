import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:caresync/features/medications/medication_repository.dart';
import 'package:caresync/features/medical_records/medical_record_repository.dart';
import 'package:caresync/features/family_profiles/family_repository.dart';
import 'package:caresync/features/family_profiles/models/family_member_model.dart';

class DoctorSharePage extends StatefulWidget {
  const DoctorSharePage({super.key});

  @override
  State<DoctorSharePage> createState() => _DoctorSharePageState();
}

class _DoctorSharePageState extends State<DoctorSharePage> {
  final _medRepo = MedicationRepository();
  final _recRepo = MedicalRecordRepository();
  final _famRepo = FamilyRepository();

  List<FamilyMember> _members = [];
  FamilyMember? _selected;
  bool _generating = false;
  String? _savedPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      await _famRepo.init();
      final members = _famRepo.getAll();
      setState(() {
        _members = members;
        if (members.isNotEmpty) _selected = members.first;
      });
    } catch (_) {}
  }

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _savedPath = null;
      _error = null;
    });

    try {
      await _medRepo.init();
      await _recRepo.init();

      final meds = _medRepo.getAll();
      final records = _recRepo.getAll();
      final now = DateTime.now();
      final dateStr = '${now.day}/${now.month}/${now.year}';

      final bytes = await _buildPdf(
        member: _selected,
        medications: meds.map((m) => {'name': m.name, 'dosage': m.dosage, 'frequency': m.frequency}).toList(),
        records: records.map((r) => {'title': r.title, 'date': r.date.toString()}).toList(),
        date: dateStr,
      );

      final dir = await getApplicationDocumentsDirectory();
      final name = _selected != null
          ? 'caresync_${_selected!.name.replaceAll(' ', '_')}_$dateStr.pdf'
              .replaceAll('/', '-')
          : 'caresync_health_summary_$dateStr.pdf'.replaceAll('/', '-');
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);

      setState(() {
        _savedPath = file.path;
        _generating = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _generating = false;
      });
    }
  }

  Future<Uint8List> _buildPdf({
    FamilyMember? member,
    required List<Map<String, dynamic>> medications,
    required List<Map<String, dynamic>> records,
    required String date,
  }) async {
    final pdf = pw.Document();
    final blue = PdfColor.fromHex('#2563EB');
    final green = PdfColor.fromHex('#10B981');
    final grey100 = PdfColor.fromHex('#F1F5F9');
    final textDark = PdfColor.fromHex('#0F172A');
    final textMid = PdfColor.fromHex('#64748B');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 20),
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: blue,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CareSync — Health Summary',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Prepared for your doctor | $date',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'CONFIDENTIAL',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        build: (ctx) => [
          // Patient info
          if (member != null) ...[
            _pdfSection(
              title: 'Patient Information',
              color: blue,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _pdfRow('Name', member.name, textDark, textMid),
                  _pdfRow('Blood Group', member.bloodGroup.isEmpty ? 'Not recorded' : member.bloodGroup, textDark, textMid),
                  _pdfRow('Insurance', member.insurance.isEmpty ? 'Not recorded' : member.insurance, textDark, textMid),
                  if (member.allergies.isNotEmpty)
                    _pdfRow('Allergies', member.allergies.join(', '), textDark, textMid),
                  if (member.chronicDiseases.isNotEmpty)
                    _pdfRow('Conditions', member.chronicDiseases.join(', '), textDark, textMid),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Medications
          _pdfSection(
            title: 'Current Medications (${medications.length})',
            color: green,
            child: medications.isEmpty
                ? pw.Text('No medications recorded.', style: pw.TextStyle(color: textMid))
                : pw.TableHelper.fromTextArray(
                    context: ctx,
                    headers: ['Medication', 'Dosage', 'Frequency'],
                    data: medications.map((m) => [m['name'], m['dosage'], m['frequency']]).toList(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      fontSize: 11,
                    ),
                    headerDecoration: pw.BoxDecoration(color: green),
                    rowDecoration: pw.BoxDecoration(color: grey100),
                    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                    cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.center, 2: pw.Alignment.center},
                    cellStyle: const pw.TextStyle(fontSize: 10),
                  ),
          ),
          pw.SizedBox(height: 16),

          // Medical records
          _pdfSection(
            title: 'Medical Records (${records.length})',
            color: PdfColor.fromHex('#8B5CF6'),
            child: records.isEmpty
                ? pw.Text('No medical records found.', style: pw.TextStyle(color: textMid))
                : pw.Column(
                    children: records.take(10).map((r) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Row(
                        children: [
                          pw.Container(width: 6, height: 6, decoration: const pw.BoxDecoration(color: PdfColors.purple, shape: pw.BoxShape.circle)),
                          pw.SizedBox(width: 8),
                          pw.Expanded(child: pw.Text(r['title'] as String, style: const pw.TextStyle(fontSize: 11))),
                          pw.Text(r['date'] as String, style: pw.TextStyle(fontSize: 10, color: textMid)),
                        ],
                      ),
                    )).toList(),
                  ),
          ),
          pw.SizedBox(height: 20),

          // Disclaimer
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#FCD34D')),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'This summary was generated by CareSync. Please verify all information with the patient and original records.',
              style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#92400E')),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfSection({required String title, required PdfColor color, required pw.Widget child}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12)),
          ),
          pw.SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  pw.Widget _pdfRow(String label, String value, PdfColor textDark, PdfColor textMid) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 110, child: pw.Text(label, style: pw.TextStyle(fontSize: 11, color: textMid))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 11, color: textDark, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share with Doctor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            _InfoBanner(),
            const SizedBox(height: 24),

            // Family member selector
            if (_members.isNotEmpty) ...[
              const Text(
                'Select Family Member',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _members.map((m) {
                  final isSelected = _selected?.id == m.id;
                  return FilterChip(
                    label: Text(m.name),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selected = m),
                    selectedColor: const Color(0xFF2563EB).withOpacity(0.15),
                    checkmarkColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade200,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // What's included
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's included in the PDF",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                  ),
                  const SizedBox(height: 10),
                  ...[
                    'Patient name, blood group & allergies',
                    'All chronic conditions',
                    'Current medications with dosage',
                    'Medical records list',
                    'Insurance information',
                  ].map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                          const SizedBox(width: 8),
                          Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Generate button
            ElevatedButton.icon(
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text(_generating ? 'Generating PDF…' : 'Generate Health Summary PDF'),
            ),

            // Success
            if (_savedPath != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'PDF Generated Successfully!',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF064E3B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saved to: $_savedPath',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF065F46)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Share this file with your doctor via email, WhatsApp, or your preferred app.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF047857)),
                    ),
                  ],
                ),
              ),
            ],

            // Error
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share with Your Doctor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Generate a professional PDF health summary to share at your next appointment.',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
