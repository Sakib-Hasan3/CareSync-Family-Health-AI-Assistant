// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 10;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String?,
      photoUrl: fields[4] as String?,
      dateOfBirth: fields[5] as DateTime?,
      gender: fields[6] as String?,
      bloodGroup: fields[7] as String?,
      address: fields[8] as String?,
      allergies: (fields[9] as List?)?.cast<String>(),
      chronicDiseases: (fields[10] as List?)?.cast<String>(),
      medications: (fields[11] as List?)?.cast<String>(),
      emergencyContact: fields[12] as String?,
      emergencyContactName: fields[13] as String?,
      insuranceProvider: fields[14] as String?,
      insurancePolicyNumber: fields[15] as String?,
      height: fields[16] as double?,
      weight: fields[17] as double?,
      createdAt: fields[18] as DateTime?,
      updatedAt: fields[19] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.dateOfBirth)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.bloodGroup)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.allergies)
      ..writeByte(10)
      ..write(obj.chronicDiseases)
      ..writeByte(11)
      ..write(obj.medications)
      ..writeByte(12)
      ..write(obj.emergencyContact)
      ..writeByte(13)
      ..write(obj.emergencyContactName)
      ..writeByte(14)
      ..write(obj.insuranceProvider)
      ..writeByte(15)
      ..write(obj.insurancePolicyNumber)
      ..writeByte(16)
      ..write(obj.height)
      ..writeByte(17)
      ..write(obj.weight)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
