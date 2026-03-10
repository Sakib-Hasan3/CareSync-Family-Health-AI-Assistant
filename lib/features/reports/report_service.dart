import 'package:caresync/features/medications/medication_repository.dart';
import 'package:caresync/features/medical_records/medical_record_repository.dart';

class MonthlyReportService {
  final _medRepo = MedicationRepository();
  final _recRepo = MedicalRecordRepository();

  /// Assembles the simple data structure expected by the PDF generator.
  /// This keeps domain-specific logic here so the generator only handles layout.
  Future<Map<String, dynamic>> assembleReportData({DateTime? forMonth}) async {
    final month = forMonth ?? DateTime.now();

    try {
      await _medRepo.init();
    } catch (_) {}
    try {
      await _recRepo.init();
    } catch (_) {}

    final meds = _medRepo.getAll();
    final records = _recRepo.getAll();

    // Medication progress: naive adherence estimate based on remaining count
    final medProgress = meds.map((m) {
      final remaining = (m.remaining <= 0) ? 0 : m.remaining;
      final adherence = ((remaining / 30.0) * 100).clamp(0, 100).toInt();
      return {'name': m.name, 'dosage': m.dosage, 'adherence': adherence};
    }).toList();

    // Build a simple summary
    final summary = <String, String>{
      'Month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
      'Medications Tracked': meds.length.toString(),
      'Medical Records': records.length.toString(),
    };

    // Vitals data not available in this edition
    final vitals = <String, List<Map<String, dynamic>>>{};

    return {
      'summary': summary,
      'medProgress': medProgress,
      'vitals': vitals,
      'appointments': <Map<String, dynamic>>[],
    };
  }
}
