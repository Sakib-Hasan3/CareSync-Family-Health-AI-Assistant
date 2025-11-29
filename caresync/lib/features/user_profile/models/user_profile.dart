import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 10)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? phone;

  @HiveField(4)
  String? photoUrl;

  @HiveField(5)
  DateTime? dateOfBirth;

  @HiveField(6)
  String? gender;

  @HiveField(7)
  String? bloodGroup;

  @HiveField(8)
  String? address;

  @HiveField(9)
  List<String>? allergies;

  @HiveField(10)
  List<String>? chronicDiseases;

  @HiveField(11)
  List<String>? medications;

  @HiveField(12)
  String? emergencyContact;

  @HiveField(13)
  String? emergencyContactName;

  @HiveField(14)
  String? insuranceProvider;

  @HiveField(15)
  String? insurancePolicyNumber;

  @HiveField(16)
  double? height; // in cm

  @HiveField(17)
  double? weight; // in kg

  @HiveField(18)
  DateTime createdAt;

  @HiveField(19)
  DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.address,
    this.allergies,
    this.chronicDiseases,
    this.medications,
    this.emergencyContact,
    this.emergencyContactName,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.height,
    this.weight,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? address,
    List<String>? allergies,
    List<String>? chronicDiseases,
    List<String>? medications,
    String? emergencyContact,
    String? emergencyContactName,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    double? height,
    double? weight,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      medications: medications ?? this.medications,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNumber: insurancePolicyNumber ?? this.insurancePolicyNumber,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'bloodGroup': bloodGroup,
        'address': address,
        'allergies': allergies,
        'chronicDiseases': chronicDiseases,
        'medications': medications,
        'emergencyContact': emergencyContact,
        'emergencyContactName': emergencyContactName,
        'insuranceProvider': insuranceProvider,
        'insurancePolicyNumber': insurancePolicyNumber,
        'height': height,
        'weight': weight,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        photoUrl: json['photoUrl'] as String?,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        gender: json['gender'] as String?,
        bloodGroup: json['bloodGroup'] as String?,
        address: json['address'] as String?,
        allergies: (json['allergies'] as List<dynamic>?)?.cast<String>(),
        chronicDiseases:
            (json['chronicDiseases'] as List<dynamic>?)?.cast<String>(),
        medications: (json['medications'] as List<dynamic>?)?.cast<String>(),
        emergencyContact: json['emergencyContact'] as String?,
        emergencyContactName: json['emergencyContactName'] as String?,
        insuranceProvider: json['insuranceProvider'] as String?,
        insurancePolicyNumber: json['insurancePolicyNumber'] as String?,
        height: json['height'] as double?,
        weight: json['weight'] as double?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  double? get bmi {
    if (height == null || weight == null || height == 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }
}
