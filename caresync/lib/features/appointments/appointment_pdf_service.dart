import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'models/appointment.dart';

/// Service to generate and save Appointment PDFs.
/// Uses the `pdf` package to render and `file_picker` to save on desktop/mobile.
class AppointmentPdfService {
  static final AppointmentPdfService _instance =
      AppointmentPdfService._internal();
  factory AppointmentPdfService() => _instance;
  AppointmentPdfService._internal();

  /// Generate a nicely formatted PDF for the given appointment.
  Future<Uint8List> generatePdfBytes(Appointment a) async {
    final pdf = pw.Document();

    final titleStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue800,
    );
    final labelStyle = pw.TextStyle(fontSize: 11, color: PdfColors.grey700);
    final valueStyle = const pw.TextStyle(fontSize: 12);

    pw.Widget row(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(width: 140, child: pw.Text(label, style: labelStyle)),
          pw.Expanded(child: pw.Text(value, style: valueStyle)),
        ],
      ),
    );

    String fmtDateTime(DateTime d) {
      final h = d.hour;
      final m = d.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final dh = h % 12 == 0 ? 12 : h % 12;
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}  $dh:$m $period';
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        ),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CareSync', style: titleStyle),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Appointment Confirmation',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: a.id,
                width: 60,
                height: 60,
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 12),

          // Appointment details
          pw.Text(
            'Appointment Details',
            style: titleStyle.copyWith(fontSize: 16),
          ),
          pw.SizedBox(height: 8),
          row('Appointment ID', a.id),
          row('Title', a.title.isNotEmpty ? a.title : 'Appointment'),
          row('Date & Time', fmtDateTime(a.datetime)),
          if (a.notes != null && a.notes!.isNotEmpty) row('Notes', a.notes!),

          pw.SizedBox(height: 16),
          pw.Text('Doctor', style: titleStyle.copyWith(fontSize: 16)),
          pw.SizedBox(height: 8),
          row('Name', a.doctor),
          if ((a.specialty ?? '').isNotEmpty)
            row('Specialization', a.specialty!),

          pw.SizedBox(height: 16),
          pw.Text('Medical Center', style: titleStyle.copyWith(fontSize: 16)),
          pw.SizedBox(height: 8),
          row('Name', a.centerName ?? a.location),
          if (a.location.isNotEmpty) row('Address', a.location),
          if ((a.centerContactPhone ?? '').isNotEmpty)
            row('Phone', a.centerContactPhone!),
          if ((a.centerContactEmail ?? '').isNotEmpty)
            row('Email', a.centerContactEmail!),

          pw.SizedBox(height: 16),
          pw.Text('Patient', style: titleStyle.copyWith(fontSize: 16)),
          pw.SizedBox(height: 8),
          if ((a.patientName ?? '').isNotEmpty)
            row('Full Name', a.patientName!),
          if (a.patientDob != null)
            row(
              'Date of Birth',
              '${a.patientDob!.day.toString().padLeft(2, '0')}/'
                  '${a.patientDob!.month.toString().padLeft(2, '0')}/'
                  '${a.patientDob!.year}',
            ),
          if ((a.patientGender ?? '').isNotEmpty)
            row('Gender', a.patientGender!),
          if ((a.patientPhone ?? '').isNotEmpty)
            row('Contact Number', a.patientPhone!),
          if ((a.patientEmail ?? '').isNotEmpty) row('Email', a.patientEmail!),
          if ((a.patientNationalId ?? '').isNotEmpty)
            row('National/Patient ID', a.patientNationalId!),

          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blue200, width: 0.5),
            ),
            child: pw.Text(
              'Please arrive 10 minutes early and bring any relevant medical records or ID.',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),

          pw.SizedBox(height: 24),
          pw.Center(
            child: pw.Text(
              'Generated by CareSync',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Open a Save dialog and write the PDF to disk. Returns the saved path or null.
  Future<String?> savePdfWithPicker(Appointment a) async {
    final bytes = await generatePdfBytes(a);

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save appointment PDF',
      fileName: 'appointment_${a.id}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (savePath == null) return null; // cancelled

    final file = File(savePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
