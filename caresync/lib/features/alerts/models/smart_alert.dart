import 'package:hive/hive.dart';

/// Manual Hive-backed SmartAlert model + adapter (no codegen needed)
class SmartAlert {
  String id;
  String type; // e.g., medication_low, appointment_upcoming, vaccine_due
  String title;
  String message;
  DateTime createdAt;
  bool acknowledged;
  String? referenceId;

  SmartAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    DateTime? createdAt,
    this.acknowledged = false,
    this.referenceId,
  }) : createdAt = createdAt ?? DateTime.now();
}

class SmartAlertAdapter extends TypeAdapter<SmartAlert> {
  @override
  final int typeId = 203;

  @override
  SmartAlert read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SmartAlert(
      id: fields[0] as String,
      type: fields[1] as String,
      title: fields[2] as String,
      message: fields[3] as String,
      createdAt: fields[4] as DateTime,
      acknowledged: fields[5] as bool,
      referenceId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SmartAlert obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.acknowledged)
      ..writeByte(6)
      ..write(obj.referenceId);
  }
}
