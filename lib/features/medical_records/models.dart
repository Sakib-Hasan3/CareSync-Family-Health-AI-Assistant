enum RecordCategory { labReport, prescription, vaccine, ecg, xray }

extension RecordCategoryLabel on RecordCategory {
  String get label {
    switch (this) {
      case RecordCategory.labReport:
        return 'Lab Report';
      case RecordCategory.prescription:
        return 'Prescription';
      case RecordCategory.vaccine:
        return 'Vaccine';
      case RecordCategory.ecg:
        return 'ECG';
      case RecordCategory.xray:
        return 'X-Ray';
    }
  }
}

// Use the Hive-backed `MedicalRecord` model located at
// `models/medical_record.dart`. This file only contains the
// `RecordCategory` enum and related helpers to avoid duplicate
// class declarations.
