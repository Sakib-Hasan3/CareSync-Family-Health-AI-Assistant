import 'dart:typed_data';

import 'package:hive/hive.dart';

class MedicalRecord extends HiveObject {
  String id;
  String title;
  String type; // lab, prescription, vaccination, scan, other
  DateTime date;
  String notes;
  String location; // local path or cloud url
  String? attachmentName;
  Uint8List? attachmentData;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.notes = '',
    this.location = '',
    this.attachmentName,
    this.attachmentData,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => MedicalRecord(
    id: json['id'] as String,
    title: json['title'] as String,
    type: json['type'] as String,
    date: DateTime.parse(json['date'] as String),
    notes: json['notes'] ?? '',
    location: json['location'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'date': date.toIso8601String(),
    'notes': notes,
    'location': location,
    'attachmentName': attachmentName,
    // do not include raw attachmentData in JSON by default
  };
}

class MedicalRecordAdapter extends TypeAdapter<MedicalRecord> {
  @override
  final int typeId = 201;

  @override
  MedicalRecord read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return MedicalRecord(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as String,
      date: fields[3] as DateTime,
      notes: fields[4] as String? ?? '',
      location: fields[5] as String? ?? '',
      attachmentName: fields[6] as String?,
      attachmentData: fields[7] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.attachmentName)
      ..writeByte(7)
      ..write(obj.attachmentData);
  }
}
