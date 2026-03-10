// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallLogAdapter extends TypeAdapter<CallLog> {
  @override
  final int typeId = 7;

  @override
  CallLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallLog(
      id: fields[0] as String,
      contactId: fields[1] as String,
      contactName: fields[2] as String,
      phoneNumber: fields[3] as String,
      timestamp: fields[4] as DateTime,
      contactType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CallLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactId)
      ..writeByte(2)
      ..write(obj.contactName)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.contactType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
