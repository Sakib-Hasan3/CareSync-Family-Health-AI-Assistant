import 'package:hive/hive.dart';

/// Manual Hive model + adapter (no codegen). typeId = 220
class VaccinationRecord {
  String id;
  String memberId;
  String memberName;
  String vaccineName;
  int doseNumber;
  DateTime dateGiven;
  DateTime? nextDueDate;
  String notes;

  VaccinationRecord({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.vaccineName,
    this.doseNumber = 1,
    required this.dateGiven,
    this.nextDueDate,
    this.notes = '',
  });
}

class VaccinationRecordAdapter extends TypeAdapter<VaccinationRecord> {
  @override
  final int typeId = 220;

  @override
  VaccinationRecord read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return VaccinationRecord(
      id: f[0] as String,
      memberId: f[1] as String,
      memberName: f[2] as String,
      vaccineName: f[3] as String,
      doseNumber: f[4] as int? ?? 1,
      dateGiven: f[5] as DateTime,
      nextDueDate: f[6] as DateTime?,
      notes: f[7] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, VaccinationRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.memberName)
      ..writeByte(3)
      ..write(obj.vaccineName)
      ..writeByte(4)
      ..write(obj.doseNumber)
      ..writeByte(5)
      ..write(obj.dateGiven)
      ..writeByte(6)
      ..write(obj.nextDueDate)
      ..writeByte(7)
      ..write(obj.notes);
  }
}
