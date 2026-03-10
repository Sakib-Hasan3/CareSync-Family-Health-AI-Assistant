import 'package:hive/hive.dart';

class Donor {
  String id;
  String name;
  String bloodGroup; // e.g. A+, O-
  String phone;
  String city;
  DateTime? lastDonated;
  bool available;
  String? notes;

  Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.phone,
    required this.city,
    this.lastDonated,
    this.available = true,
    this.notes,
  });

  factory Donor.fromJson(Map<String, dynamic> j) => Donor(
    id: j['id'] as String,
    name: j['name'] as String,
    bloodGroup: j['bloodGroup'] as String,
    phone: j['phone'] as String,
    city: j['city'] as String,
    lastDonated: j['lastDonated'] == null
        ? null
        : DateTime.parse(j['lastDonated']),
    available: j['available'] ?? true,
    notes: j['notes'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bloodGroup': bloodGroup,
    'phone': phone,
    'city': city,
    'lastDonated': lastDonated?.toIso8601String(),
    'available': available,
    'notes': notes,
  };
}

class DonorAdapter extends TypeAdapter<Donor> {
  @override
  final int typeId = 210;

  @override
  Donor read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < n; i++) fields[reader.readByte()] = reader.read();
    return Donor(
      id: fields[0] as String,
      name: fields[1] as String,
      bloodGroup: fields[2] as String,
      phone: fields[3] as String,
      city: fields[4] as String,
      lastDonated: fields[5] as DateTime?,
      available: fields[6] as bool? ?? true,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Donor obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bloodGroup)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.lastDonated)
      ..writeByte(6)
      ..write(obj.available)
      ..writeByte(7)
      ..write(obj.notes);
  }
}
