/// Family member model
class FamilyMember {
  final String id;
  final String userId; // ID of the user who added this family member
  final String name;
  final DateTime dateOfBirth;
  final String relationship;
  final String? bloodType;
  final List<String> allergies;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? emergencyContact;
  final Map<String, dynamic>? medicalConditions;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    required this.relationship,
    this.bloodType,
    this.allergies = const [],
    this.profileImageUrl,
    this.phoneNumber,
    this.emergencyContact,
    this.medicalConditions,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Create FamilyMember from JSON
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      relationship: json['relationship'] as String,
      bloodType: json['bloodType'] as String?,
      allergies: List<String>.from(json['allergies'] as List? ?? []),
      profileImageUrl: json['profileImageUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      medicalConditions: json['medicalConditions'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert FamilyMember to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'relationship': relationship,
      'bloodType': bloodType,
      'allergies': allergies,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'emergencyContact': emergencyContact,
      'medicalConditions': medicalConditions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  FamilyMember copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? dateOfBirth,
    String? relationship,
    String? bloodType,
    List<String>? allergies,
    String? profileImageUrl,
    String? phoneNumber,
    String? emergencyContact,
    Map<String, dynamic>? medicalConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      relationship: relationship ?? this.relationship,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyMember && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FamilyMember(id: $id, name: $name, relationship: $relationship)';
  }
}
