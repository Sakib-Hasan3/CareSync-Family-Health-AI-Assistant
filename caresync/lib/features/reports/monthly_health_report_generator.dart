import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

/// Generates a monthly health report PDF.
///
/// The simple API accepts already-prepared data so the app can assemble
/// medication progress, vitals, appointments and a short summary and pass
/// them in. This keeps the generator focused on layout and export.
class MonthlyHealthReportGenerator {
  /// Generates the PDF and returns bytes.
  ///
  /// - [summary] is a short map of key -> value strings describing the month summary.
  /// - [medProgress] is a list of medication maps with keys: `name`, `dosage`, `adherence` (0-100).
  /// - [vitals] is a map where the key is the vital name and the value is a list of
  ///   maps with `date` (DateTime) and `value` (num).
  /// - [appointments] is a list of maps with `date`, `doctor`, `notes`.
  static Future<Uint8List> generatePdfBytes({
    required Map<String, String> summary,
    required List<Map<String, dynamic>> medProgress,
    required Map<String, List<Map<String, dynamic>>> vitals,
    required List<Map<String, dynamic>> appointments,
    String title = 'Monthly Health Report',
    DateTime? forMonth,
  }) async {
    final pdf = pw.Document();
    final month = forMonth ?? DateTime.now();
    final monthLabel =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';

    // Simple header
    final header = pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Report month: $monthLabel',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            'CareSync',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.blue700),
          ),
        ),
      ],
    );

    // Summary section
    final summaryWidget = pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Health Summary',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Column(
            children: summary.entries
                .map(
                  (e) => pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text('${e.key}:')),
                      pw.Text(e.value),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );

    // Medication progress table builder (uses TableHelper.fromTextArray inside page context)
    pw.Widget buildMedTable(pw.Context ctx) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Medication Progress',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              context: ctx,
              headers: ['Medication', 'Dosage', 'Adherence'],
              data: medProgress
                  .map(
                    (m) => [
                      m['name'] ?? '',
                      m['dosage'] ?? '',
                      '${m['adherence'] ?? 0}%',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
            ),
          ],
        ),
      );
    }

    // Vitals list + simple bar visuals
    pw.Widget buildVitals() {
      final children = <pw.Widget>[];
      vitals.forEach((name, samples) {
        children.add(
          pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        );
        // Show last 6 samples as small bars
        final last = samples.take(6).toList();
        final values = last.map((s) => (s['value'] as num).toDouble()).toList();
        final maxVal = values.isEmpty
            ? 1.0
            : values.reduce((a, b) => a > b ? a : b);
        children.add(pw.SizedBox(height: 6));
        children.add(
          pw.Row(
            children: values.map((v) {
              final h = maxVal > 0 ? (40.0 * (v / maxVal)) : 4.0;
              return pw.Expanded(
                child: pw.Container(
                  height: h,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue300,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
              );
            }).toList(),
          ),
        );
        children.add(pw.SizedBox(height: 8));
        // Also list the most recent sample
        if (samples.isNotEmpty) {
          final s = samples.first;
          children.add(
            pw.Text(
              'Latest: ${s['value']} on ${(s['date'] as DateTime).toLocal().toString().split(' ').first}',
            ),
          );
        }
        children.add(pw.SizedBox(height: 10));
      });
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Vitals',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...children,
          ],
        ),
      );
    }

    // Appointments list
    final appointmentsWidget = pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Appointments',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (appointments.isEmpty) pw.Text('No appointments this month.'),
          ...appointments.map(
            (a) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${(a['date'] as DateTime).toLocal().toString().split(' ').first} — ${a['doctor'] ?? ''}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if ((a['notes'] ?? '').toString().isNotEmpty)
                  pw.Text(a['notes'] ?? ''),
                pw.SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          header,
          pw.SizedBox(height: 12),
          summaryWidget,
          pw.SizedBox(height: 12),
          buildMedTable(context),
          pw.SizedBox(height: 12),
          buildVitals(),
          pw.SizedBox(height: 12),
          appointmentsWidget,
        ],
      ),
    );

    return pdf.save();
  }
}
