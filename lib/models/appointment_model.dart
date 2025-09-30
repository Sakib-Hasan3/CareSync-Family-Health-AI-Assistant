/// Appointment status enum
enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

/// Appointment type enum
enum AppointmentType {
  checkup,
  consultation,
  followUp,
  emergency,
  vaccination,
  surgery,
  therapy,
  other,
}

/// Appointment model
class Appointment {
  final String id;
  final String userId;
  final String? familyMemberId;
  final String doctorName;
  final String? specialty;
  final DateTime appointmentDateTime;
  final String location;
  final String? address;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? notes;
  final String? reason;
  final Duration? estimatedDuration;
  final String? phoneNumber;
  final bool reminderSet;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    this.familyMemberId,
    required this.doctorName,
    this.specialty,
    required this.appointmentDateTime,
    required this.location,
    this.address,
    required this.type,
    this.status = AppointmentStatus.scheduled,
    this.notes,
    this.reason,
    this.estimatedDuration,
    this.phoneNumber,
    this.reminderSet = false,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if appointment is upcoming (in the future)
  bool get isUpcoming {
    return appointmentDateTime.isAfter(DateTime.now()) &&
        status != AppointmentStatus.cancelled &&
        status != AppointmentStatus.completed;
  }

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return appointmentDateTime.year == now.year &&
        appointmentDateTime.month == now.month &&
        appointmentDateTime.day == now.day;
  }

  /// Check if appointment is overdue
  bool get isOverdue {
    return appointmentDateTime.isBefore(DateTime.now()) &&
        status == AppointmentStatus.scheduled;
  }

  /// Get time until appointment
  Duration? get timeUntilAppointment {
    if (appointmentDateTime.isBefore(DateTime.now())) return null;
    return appointmentDateTime.difference(DateTime.now());
  }

  /// Get status description
  String get statusDescription {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  /// Get type description
  String get typeDescription {
    switch (type) {
      case AppointmentType.checkup:
        return 'Check-up';
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.vaccination:
        return 'Vaccination';
      case AppointmentType.surgery:
        return 'Surgery';
      case AppointmentType.therapy:
        return 'Therapy';
      case AppointmentType.other:
        return 'Other';
    }
  }

  /// Create Appointment from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      familyMemberId: json['familyMemberId'] as String?,
      doctorName: json['doctorName'] as String,
      specialty: json['specialty'] as String?,
      appointmentDateTime: DateTime.parse(
        json['appointmentDateTime'] as String,
      ),
      location: json['location'] as String,
      address: json['address'] as String?,
      type: AppointmentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AppointmentType.checkup,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      notes: json['notes'] as String?,
      reason: json['reason'] as String?,
      estimatedDuration: json['estimatedDuration'] != null
          ? Duration(minutes: json['estimatedDuration'] as int)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
      reminderSet: json['reminderSet'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Appointment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'familyMemberId': familyMemberId,
      'doctorName': doctorName,
      'specialty': specialty,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'location': location,
      'address': address,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'notes': notes,
      'reason': reason,
      'estimatedDuration': estimatedDuration?.inMinutes,
      'phoneNumber': phoneNumber,
      'reminderSet': reminderSet,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Appointment copyWith({
    String? id,
    String? userId,
    String? familyMemberId,
    String? doctorName,
    String? specialty,
    DateTime? appointmentDateTime,
    String? location,
    String? address,
    AppointmentType? type,
    AppointmentStatus? status,
    String? notes,
    String? reason,
    Duration? estimatedDuration,
    String? phoneNumber,
    bool? reminderSet,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      location: location ?? this.location,
      address: address ?? this.address,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      reason: reason ?? this.reason,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      reminderSet: reminderSet ?? this.reminderSet,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Appointment(id: $id, doctor: $doctorName, date: $appointmentDateTime)';
  }
}
