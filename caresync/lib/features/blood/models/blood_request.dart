import 'package:hive/hive.dart';

class BloodRequest {
  String id;
  String requesterName;
  String bloodGroupNeeded;
  int units;
  String urgency; // low/medium/high
  String locationCity;
  String contactPhone;
  DateTime createdAt;
  List<String> matchedDonorIds;
  String status; // open/matched/closed

  BloodRequest({
    required this.id,
    required this.requesterName,
    required this.bloodGroupNeeded,
    required this.units,
    required this.urgency,
    required this.locationCity,
    required this.contactPhone,
    DateTime? createdAt,
    List<String>? matchedDonorIds,
    this.status = 'open',
  }) : createdAt = createdAt ?? DateTime.now(),
       matchedDonorIds = matchedDonorIds ?? [];
}

class BloodRequestAdapter extends TypeAdapter<BloodRequest> {
  @override
  final int typeId = 211;

  @override
  BloodRequest read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) f[reader.readByte()] = reader.read();
    return BloodRequest(
      id: f[0] as String,
      requesterName: f[1] as String,
      bloodGroupNeeded: f[2] as String,
      units: f[3] as int,
      urgency: f[4] as String,
      locationCity: f[5] as String,
      contactPhone: f[6] as String,
      createdAt: f[7] as DateTime,
      matchedDonorIds: (f[8] as List?)?.cast<String>() ?? [],
      status: f[9] as String? ?? 'open',
    );
  }

  @override
  void write(BinaryWriter writer, BloodRequest obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.requesterName)
      ..writeByte(2)
      ..write(obj.bloodGroupNeeded)
      ..writeByte(3)
      ..write(obj.units)
      ..writeByte(4)
      ..write(obj.urgency)
      ..writeByte(5)
      ..write(obj.locationCity)
      ..writeByte(6)
      ..write(obj.contactPhone)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.matchedDonorIds)
      ..writeByte(9)
      ..write(obj.status);
  }
}
