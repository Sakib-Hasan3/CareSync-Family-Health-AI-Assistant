import 'dart:async';
import 'medical_record_repository.dart';
import 'models/medical_record.dart';

/// Lightweight cloud-sync stub. Replace with real cloud storage (Firebase,
/// S3, etc.) integrations later.
class MedicalRecordSyncService {
  final MedicalRecordRepository _repo;

  MedicalRecordSyncService({MedicalRecordRepository? repository})
    : _repo = repository ?? MedicalRecordRepository();

  Future<void> syncUp() async {
    // stub: upload local records to cloud
    // touch the repository so the field is used and the analyzer is quiet
    final local = _repo.getAll();
    assert(local.length >= 0);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> syncDown() async {
    // stub: download remote records
    final local = _repo.getAll();
    assert(local.length >= 0);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<List<MedicalRecord>> fetchRemote() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }
}
