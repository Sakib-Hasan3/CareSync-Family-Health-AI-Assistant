import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'models/appointment.dart';

// Conditional downloader: uses web implementation when compiled for web.
import 'pdf_downloader_io.dart'
    if (dart.library.html) 'pdf_downloader_web.dart'
    as pdf_downloader;

class AppointmentPdfGenerator {
  static Future<Uint8List> generatePdfBytes(
    Appointment appointment,
    String departmentName,
    String paymentMethod,
    String transactionId,
  ) async {
    final pdf = pw.Document();

    // Add professional header with logo placeholder
    final header = pw.Row(
      children: [
        pw.Container(
          width: 50,
          height: 50,
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue700,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              'FH',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Family Health Care',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.Text(
              'Quality Healthcare for Your Family',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );

    // Appointment details section
    final appointmentDetails = pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Appointment Details',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildDetailRow('Appointment ID', appointment.id),
          _buildDetailRow('Department', departmentName),
          _buildDetailRow('Doctor', appointment.doctorName ?? ''),
          _buildDetailRow('Date', _formatDate(appointment.dateTime)),
          _buildDetailRow('Time', _formatTime(appointment.dateTime)),
          if (appointment.notes != null && appointment.notes!.isNotEmpty)
            _buildDetailRow('Notes', appointment.notes!),
        ],
      ),
    );

    // Payment information section
    final paymentInfo = pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Payment Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildDetailRow('Payment Method', paymentMethod),
          _buildDetailRow('Transaction ID', transactionId),
          _buildDetailRow('Status', 'Confirmed'),
          _buildDetailRow('Generated On', _formatDate(DateTime.now())),
        ],
      ),
    );

    // Contact information
    final contactInfo = pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Need to Reschedule?',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Please contact us at least 24 hours in advance if you need to reschedule or cancel your appointment.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          _buildContactRow('Phone', '+1 (555) 123-HEAL'),
          _buildContactRow('Email', 'support@familyhealth.com'),
          _buildContactRow('Address', '123 Healthcare Ave, Medical City'),
        ],
      ),
    );

    // Build the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                header,
                pw.SizedBox(height: 24),
                // Success message
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      border: pw.Border.all(color: PdfColors.green300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Icon(
                          pw.IconData(0x2713), // Check mark
                          color: PdfColors.green,
                          size: 16,
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          'Appointment Confirmed Successfully!',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),
                appointmentDetails,
                pw.SizedBox(height: 16),
                paymentInfo,
                pw.SizedBox(height: 16),
                contactInfo,
                pw.SizedBox(height: 24),
                // Footer
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Text(
                    'Thank you for choosing Family Health Care',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildContactRow(String type, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              '$type:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Try to open or save PDF bytes depending on platform.
  static Future<void> openPdfBytes(Uint8List bytes, String filename) async {
    try {
      await pdf_downloader.downloadPdf(bytes, filename);
    } catch (e) {
      // If download/open fails, swallow silently to avoid crashing UI.
    }
  }
}

// Fallback text generator for compatibility
class AppointmentPdf {
  static List<int> generatePlainText(Appointment a) {
    final b = StringBuffer();
    b.writeln('╔══════════════════════════════════════════════════╗');
    b.writeln('║           FAMILY HEALTH CARE                     ║');
    b.writeln('║           Appointment Confirmation               ║');
    b.writeln('╚══════════════════════════════════════════════════╝');
    b.writeln('');
    b.writeln('▀▀▀▀▀▀▀▀▀▀▀ APPOINTMENT DETAILS ▀▀▀▀▀▀▀▀▀▀▀');
    b.writeln('┌───────────────────┬─────────────────────────────┐');
    b.writeln('│ Appointment ID    │ ${a.id.padRight(30)} │');
    b.writeln('│ Doctor            │ ${a.doctorName.padRight(30)} │');
    if (a.specialty != null) {
      b.writeln('│ Specialty         │ ${a.specialty!.padRight(30)} │');
    }
    b.writeln(
      '│ Date & Time       │ ${a.dateTime.toLocal().toString().padRight(30)} │',
    );
    if ((a.patientName ?? '').isNotEmpty) {
      b.writeln('│ Patient Name      │ ${a.patientName!.padRight(30)} │');
    }
    if ((a.notes ?? '').isNotEmpty) {
      b.writeln('│ Notes             │ ${a.notes!.padRight(30)} │');
    }
    b.writeln('└───────────────────┴─────────────────────────────┘');
    b.writeln('');
    b.writeln('▀▀▀▀▀▀▀▀▀▀▀▀ CONTACT INFORMATION ▀▀▀▀▀▀▀▀▀▀▀▀');
    b.writeln('📍 ${a.clinic}');
    if ((a.centerContactPhone ?? '').isNotEmpty) {
      b.writeln('📞 ${a.centerContactPhone}');
    }
    if ((a.centerContactEmail ?? '').isNotEmpty) {
      b.writeln('📧 ${a.centerContactEmail}');
    }
    b.writeln('');
    b.writeln('▀▀▀▀▀▀▀▀▀▀▀▀▀ IMPORTANT NOTES ▀▀▀▀▀▀▀▀▀▀▀▀▀');
    b.writeln('• Please arrive 15 minutes before your appointment');
    b.writeln('• Bring your ID and insurance card');
    b.writeln('• Contact us 24h in advance for cancellations');
    b.writeln('');
    b.writeln('╔══════════════════════════════════════════════════╗');
    b.writeln('║      Thank you for choosing Family Health Care   ║');
    b.writeln('╚══════════════════════════════════════════════════╝');
    b.writeln('Generated on: ${DateTime.now().toLocal()}');

    return b.toString().codeUnits;
  }
}
