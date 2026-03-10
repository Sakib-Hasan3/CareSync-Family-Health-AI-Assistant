import 'package:hive/hive.dart';

part 'family_member_model.g.dart';

@HiveType(typeId: 0)
class FamilyMember {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String bloodGroup;

  @HiveField(3)
  List<String> allergies;

  @HiveField(4)
  List<String> chronicDiseases;

  @HiveField(5)
  List<String> medications;

  @HiveField(6)
  String insurance;

  @HiveField(7)
  Map<String, String> emergencyContacts;

  FamilyMember({
    required this.id,
    required this.name,
    this.bloodGroup = '',
    List<String>? allergies,
    List<String>? chronicDiseases,
    List<String>? medications,
    this.insurance = '',
    Map<String, String>? emergencyContacts,
  }) : allergies = allergies ?? [],
       chronicDiseases = chronicDiseases ?? [],
       medications = medications ?? [],
       emergencyContacts = emergencyContacts ?? {};

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'] as String,
    name: json['name'] as String,
    bloodGroup: json['bloodGroup'] as String? ?? '',
    allergies: (json['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
    chronicDiseases:
        (json['chronicDiseases'] as List<dynamic>?)?.cast<String>() ?? [],
    medications: (json['medications'] as List<dynamic>?)?.cast<String>() ?? [],
    insurance: json['insurance'] as String? ?? '',
    emergencyContacts:
        (json['emergencyContacts'] as Map<dynamic, dynamic>?)?.map(
          (k, v) => MapEntry(k as String, v as String),
        ) ??
        {},
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bloodGroup': bloodGroup,
    'allergies': allergies,
    'chronicDiseases': chronicDiseases,
    'medications': medications,
    'insurance': insurance,
    'emergencyContacts': emergencyContacts,
  };
}
