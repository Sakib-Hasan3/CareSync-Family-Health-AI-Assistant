import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'models.dart';
import 'models/medical_record.dart' as hmodel;

class MedicalRecordRepository {
  static const _boxName = 'medical_records';
  Box<hmodel.MedicalRecord>? _box;
  Directory? _storageDir;

  Future<void> init() async {
    // Ensure the Hive adapter for the existing MedicalRecord model is registered
    if (!Hive.isAdapterRegistered(201)) {
      Hive.registerAdapter(hmodel.MedicalRecordAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<hmodel.MedicalRecord>(_boxName);
    } else {
      _box = Hive.box<hmodel.MedicalRecord>(_boxName);
    }

    _storageDir ??= await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(_storageDir!.path, 'medical_records'));
    if (!await dir.exists()) await dir.create(recursive: true);
    _storageDir = dir;
  }

  List<hmodel.MedicalRecord> getAll() {
    return _box?.values.toList() ?? [];
  }

  Future<hmodel.MedicalRecord> addFromPath({
    required String srcPath,
    required String name,
    required RecordCategory category,
    String? mimeType,
  }) async {
    if (_box == null) await init();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final filename = p.basename(srcPath);
    final dest = p.join(_storageDir!.path, '${id}_$filename');
    final srcFile = File(srcPath);
    await srcFile.copy(dest);

    // Map our RecordCategory to a simple type string used by the existing model
    final typeStr = category.label.toLowerCase();
    final rec = hmodel.MedicalRecord(
      id: id,
      title: name,
      type: typeStr,
      date: DateTime.now(),
      notes: '',
      location: dest,
      attachmentName: filename,
      attachmentData: null,
    );
    await _box!.put(id, rec);
    return rec;
  }

  Future<void> delete(hmodel.MedicalRecord r) async {
    try {
      final f = File(r.location);
      if (await f.exists()) await f.delete();
    } catch (_) {}
    await _box?.delete(r.id);
  }

  Future<void> export(hmodel.MedicalRecord r, String destPath) async {
    final f = File(r.location);
    if (await f.exists()) {
      await f.copy(destPath);
    } else {
      throw Exception('File not found');
    }
  }
}
