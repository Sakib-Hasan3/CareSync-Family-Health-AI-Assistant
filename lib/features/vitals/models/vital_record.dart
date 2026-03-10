import 'package:hive/hive.dart';

const kVitalTypes = [
  'Blood Pressure',
  'Heart Rate',
  'Blood Sugar',
  'Temperature',
  'SpO₂',
  'Weight',
  'Respiratory Rate',
];

const kVitalUnits = {
  'Blood Pressure': 'mmHg',
  'Heart Rate': 'bpm',
  'Blood Sugar': 'mg/dL',
  'Temperature': '°C',
  'SpO₂': '%',
  'Weight': 'kg',
  'Respiratory Rate': 'brpm',
};

class VitalRecord {
  String id;
  String memberId;
  String memberName;
  String type; // one of kVitalTypes
  double value1; // primary value; systolic for BP
  double? value2; // diastolic for BP
  String unit;
  DateTime timestamp;
  String notes;

  VitalRecord({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.value1,
    this.value2,
    required this.unit,
    DateTime? timestamp,
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  String get displayValue {
    if (type == 'Blood Pressure' && value2 != null) {
      return '${value1.toInt()}/${value2!.toInt()}';
    }
    return value1 % 1 == 0
        ? value1.toInt().toString()
        : value1.toStringAsFixed(1);
  }
}

class VitalRecordAdapter extends TypeAdapter<VitalRecord> {
  @override
  final int typeId = 221;

  @override
  VitalRecord read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return VitalRecord(
      id: f[0] as String,
      memberId: f[1] as String,
      memberName: f[2] as String,
      type: f[3] as String,
      value1: f[4] as double,
      value2: f[5] as double?,
      unit: f[6] as String,
      timestamp: f[7] as DateTime,
      notes: f[8] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, VitalRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.memberName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.value1)
      ..writeByte(5)
      ..write(obj.value2)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VitalRecordAdapter && typeId == other.typeId;
}
