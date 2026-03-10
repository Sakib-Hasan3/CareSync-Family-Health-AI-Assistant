import 'package:hive/hive.dart';

/// Appointment domain model stored in Hive (typeId: 202).
/// Matches existing code expectations across the app.
class Appointment {
  String id;
  late String title;
  late String doctor;
  late String location;
  late DateTime datetime;
  String? notes;
  int reminderMinutesBefore;
  bool isCompleted;
  String? familyMemberId;
  String? specialty;

  // Extended optional fields
  String? patientName;
  DateTime? patientDob;
  String? patientGender;
  String? patientPhone;
  String? patientEmail;
  String? patientNationalId;
  String? centerId;
  String? centerName;
  String? centerContactPhone;
  String? centerContactEmail;
  String? doctorId;

  Appointment({
    required this.id,
    String? title,
    String? doctor,
    String? doctorName,
    String? clinic,
    String? location,
    DateTime? datetime,
    DateTime? dateTime,
    this.notes,
    this.reminderMinutesBefore = 0,
    this.isCompleted = false,
    this.familyMemberId,
    this.specialty,
    this.patientName,
    this.patientDob,
    this.patientGender,
    this.patientPhone,
    this.patientEmail,
    this.patientNationalId,
    this.centerId,
    this.centerName,
    this.centerContactPhone,
    this.centerContactEmail,
    this.doctorId,
  }) : title = title ?? '',
       doctor = doctorName ?? doctor ?? '',
       location = clinic ?? location ?? '',
       datetime = dateTime ?? datetime ?? DateTime.now();

  // Backwards-compatible getters for callers expecting different names.
  String get doctorName => doctor;
  DateTime get dateTime => datetime;
  String get clinic => centerName ?? location;

  Appointment copyWith({
    String? id,
    String? title,
    String? doctor,
    String? doctorName,
    String? location,
    String? clinic,
    DateTime? datetime,
    DateTime? dateTime,
    String? notes,
    int? reminderMinutesBefore,
    bool? isCompleted,
    String? familyMemberId,
    String? specialty,
    String? patientName,
    DateTime? patientDob,
    String? patientGender,
    String? patientPhone,
    String? patientEmail,
    String? patientNationalId,
    String? centerId,
    String? centerName,
    String? centerContactPhone,
    String? centerContactEmail,
    String? doctorId,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      doctorName: doctorName ?? doctor ?? this.doctor,
      clinic: clinic ?? location ?? this.location,
      dateTime: dateTime ?? datetime ?? this.datetime,
      notes: notes ?? this.notes,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      isCompleted: isCompleted ?? this.isCompleted,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      specialty: specialty ?? this.specialty,
      patientName: patientName ?? this.patientName,
      patientDob: patientDob ?? this.patientDob,
      patientGender: patientGender ?? this.patientGender,
      patientPhone: patientPhone ?? this.patientPhone,
      patientEmail: patientEmail ?? this.patientEmail,
      patientNationalId: patientNationalId ?? this.patientNationalId,
      centerId: centerId ?? this.centerId,
      centerName: centerName ?? this.centerName,
      centerContactPhone: centerContactPhone ?? this.centerContactPhone,
      centerContactEmail: centerContactEmail ?? this.centerContactEmail,
      doctorId: doctorId ?? this.doctorId,
    );
  }
}

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 202;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++)
      fields[reader.readByte()] = reader.read();
    return Appointment(
      id: fields[0] as String? ?? '',
      title: fields[1] as String? ?? '',
      doctorName: fields[2] as String? ?? '',
      clinic: fields[3] as String? ?? '',
      dateTime: fields[4] as DateTime? ?? DateTime.now(),
      notes: fields[5] as String?,
      reminderMinutesBefore: fields[6] as int? ?? 0,
      isCompleted: fields[7] as bool? ?? false,
      familyMemberId: fields[8] as String?,
      specialty: fields[9] as String?,
      patientName: fields[10] as String?,
      patientDob: fields[11] as DateTime?,
      patientGender: fields[12] as String?,
      patientPhone: fields[13] as String?,
      patientEmail: fields[14] as String?,
      patientNationalId: fields[15] as String?,
      centerId: fields[16] as String?,
      centerName: fields[17] as String?,
      centerContactPhone: fields[18] as String?,
      centerContactEmail: fields[19] as String?,
      doctorId: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.doctor)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.datetime)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.familyMemberId)
      ..writeByte(9)
      ..write(obj.specialty)
      ..writeByte(10)
      ..write(obj.patientName)
      ..writeByte(11)
      ..write(obj.patientDob)
      ..writeByte(12)
      ..write(obj.patientGender)
      ..writeByte(13)
      ..write(obj.patientPhone)
      ..writeByte(14)
      ..write(obj.patientEmail)
      ..writeByte(15)
      ..write(obj.patientNationalId)
      ..writeByte(16)
      ..write(obj.centerId)
      ..writeByte(17)
      ..write(obj.centerName)
      ..writeByte(18)
      ..write(obj.centerContactPhone)
      ..writeByte(19)
      ..write(obj.centerContactEmail)
      ..writeByte(20)
      ..write(obj.doctorId);
  }
}
