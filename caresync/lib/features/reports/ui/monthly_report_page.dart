import 'package:flutter/material.dart';
import '../monthly_health_report_generator.dart';
import 'package:caresync/features/reports/report_service.dart';

// Conditional downloader: reuse the app-level downloader implementation
import 'package:caresync/features/appointments/pdf_downloader_io.dart'
    if (dart.library.html) 'package:caresync/features/appointments/pdf_downloader_web.dart'
    as pdf_downloader;

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  final _service = MonthlyReportService();
  bool _loading = false;

  Future<void> _generateAndDownload() async {
    setState(() => _loading = true);
    try {
      final data = await _service.assembleReportData();
      final bytes = await MonthlyHealthReportGenerator.generatePdfBytes(
        summary: Map<String, String>.from(data['summary'] ?? {}),
        medProgress: List<Map<String, dynamic>>.from(data['medProgress'] ?? []),
        vitals: Map<String, List<Map<String, dynamic>>>.from(
          data['vitals'] ?? {},
        ),
        appointments: List<Map<String, dynamic>>.from(
          data['appointments'] ?? [],
        ),
      );
      final filename =
          'caresync_monthly_report_${DateTime.now().toIso8601String()}.pdf';
      await pdf_downloader.downloadPdf(bytes, filename);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report generated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate report: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Health Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate a downloadable monthly summary of your health data.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Includes: medication progress, vitals chart, appointments, and a short summary.',
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : _generateAndDownload,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_loading ? 'Generating…' : 'Generate & Download PDF'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tip: open the report to share with your clinician or keep for records.',
            ),
          ],
        ),
      ),
    );
  }
}
