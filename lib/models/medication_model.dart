/// Medication frequency enum
enum MedicationFrequency {
  once,
  daily,
  twiceDaily,
  threeTimesDaily,
  fourTimesDaily,
  weekly,
  monthly,
  asNeeded,
}

/// Medication model
class Medication {
  final String id;
  final String userId;
  final String? familyMemberId;
  final String name;
  final String dosage;
  final MedicationFrequency frequency;
  final List<DateTime> reminderTimes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? instructions;
  final String? prescribedBy;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.userId,
    this.familyMemberId,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.reminderTimes = const [],
    this.startDate,
    this.endDate,
    this.instructions,
    this.prescribedBy,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if medication should be taken today
  bool get shouldTakeToday {
    if (!isActive) return false;
    if (startDate != null && DateTime.now().isBefore(startDate!)) return false;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return false;

    switch (frequency) {
      case MedicationFrequency.once:
        return startDate != null &&
            DateTime.now().difference(startDate!).inDays == 0;
      case MedicationFrequency.daily:
      case MedicationFrequency.twiceDaily:
      case MedicationFrequency.threeTimesDaily:
      case MedicationFrequency.fourTimesDaily:
        return true;
      case MedicationFrequency.weekly:
        return startDate != null &&
            DateTime.now().difference(startDate!).inDays % 7 == 0;
      case MedicationFrequency.monthly:
        return startDate != null &&
            DateTime.now().difference(startDate!).inDays % 30 == 0;
      case MedicationFrequency.asNeeded:
        return true;
    }
  }

  /// Get frequency description
  String get frequencyDescription {
    switch (frequency) {
      case MedicationFrequency.once:
        return 'Once';
      case MedicationFrequency.daily:
        return 'Once daily';
      case MedicationFrequency.twiceDaily:
        return 'Twice daily';
      case MedicationFrequency.threeTimesDaily:
        return '3 times daily';
      case MedicationFrequency.fourTimesDaily:
        return '4 times daily';
      case MedicationFrequency.weekly:
        return 'Weekly';
      case MedicationFrequency.monthly:
        return 'Monthly';
      case MedicationFrequency.asNeeded:
        return 'As needed';
    }
  }

  /// Create Medication from JSON
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      userId: json['userId'] as String,
      familyMemberId: json['familyMemberId'] as String?,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: MedicationFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == json['frequency'],
        orElse: () => MedicationFrequency.daily,
      ),
      reminderTimes: (json['reminderTimes'] as List<dynamic>? ?? [])
          .map((e) => DateTime.parse(e as String))
          .toList(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      instructions: json['instructions'] as String?,
      prescribedBy: json['prescribedBy'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Medication to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'familyMemberId': familyMemberId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency.toString().split('.').last,
      'reminderTimes': reminderTimes.map((e) => e.toIso8601String()).toList(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructions': instructions,
      'prescribedBy': prescribedBy,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Medication copyWith({
    String? id,
    String? userId,
    String? familyMemberId,
    String? name,
    String? dosage,
    MedicationFrequency? frequency,
    List<DateTime>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? instructions,
    String? prescribedBy,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, dosage: $dosage)';
  }
}
