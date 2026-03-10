import 'package:hive/hive.dart';

class Medication extends HiveObject {
  String id;

  String name;

  String dosage; // e.g. "100 mg"

  String frequency; // e.g. "Once a day"

  DateTime? nextDose; // next scheduled dose
  String time; // human-readable time e.g. '9:00 AM'

  int refillThreshold; // remaining pills threshold to alert

  int remaining; // remaining pill count

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.nextDose,
    this.refillThreshold = 5,
    this.remaining = 30,
    this.time = '',
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      nextDose: json['nextDose'] == null
          ? null
          : DateTime.parse(json['nextDose']),
      time: json['time'] ?? '',
      refillThreshold: json['refillThreshold'] ?? 5,
      remaining: json['remaining'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'frequency': frequency,
    'nextDose': nextDose?.toIso8601String(),
    'time': time,
    'refillThreshold': refillThreshold,
    'remaining': remaining,
  };

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    DateTime? nextDose,
    String? time,
    int? refillThreshold,
    int? remaining,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      nextDose: nextDose ?? this.nextDose,
      time: time ?? this.time,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      remaining: remaining ?? this.remaining,
    );
  }
}

// NOTE: We provide a simple manual adapter implementation here instead
// of relying on build_runner generated code. This keeps the feature
// usable immediately without requiring a codegen step.
class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 200;

  @override
  Medication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return Medication(
      id: fields[0] as String,
      name: fields[1] as String,
      dosage: fields[2] as String,
      frequency: fields[3] as String,
      nextDose: fields[4] as DateTime?,
      refillThreshold: fields[5] as int,
      remaining: fields[6] as int,
      time: fields[7] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.nextDose)
      ..writeByte(5)
      ..write(obj.refillThreshold)
      ..writeByte(6)
      ..write(obj.remaining);
    writer
      ..writeByte(7)
      ..write(obj.time);
  }
}
