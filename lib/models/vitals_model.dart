/// Vital signs model
class Vitals {
  final String id;
  final String userId;
  final String? familyMemberId;
  final DateTime recordedAt;
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? heartRate; // bpm
  final double? temperature; // Celsius
  final double? weight; // kg
  final double? height; // cm
  final double? bloodSugar; // mg/dL
  final double? oxygenSaturation; // %
  final String? notes;
  final Map<String, dynamic>? additionalMeasurements;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vitals({
    required this.id,
    required this.userId,
    this.familyMemberId,
    required this.recordedAt,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.temperature,
    this.weight,
    this.height,
    this.bloodSugar,
    this.oxygenSaturation,
    this.notes,
    this.additionalMeasurements,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get blood pressure reading as string
  String? get bloodPressureReading {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return null;
    }
    return '${bloodPressureSystolic!.toInt()}/${bloodPressureDiastolic!.toInt()}';
  }

  /// Check if blood pressure is normal (less than 120/80)
  bool? get isBloodPressureNormal {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return null;
    }
    return bloodPressureSystolic! < 120 && bloodPressureDiastolic! < 80;
  }

  /// Check if heart rate is normal (60-100 bpm)
  bool? get isHeartRateNormal {
    if (heartRate == null) return null;
    return heartRate! >= 60 && heartRate! <= 100;
  }

  /// Check if temperature is normal (36.1-37.2°C)
  bool? get isTemperatureNormal {
    if (temperature == null) return null;
    return temperature! >= 36.1 && temperature! <= 37.2;
  }

  /// Calculate BMI if height and weight are available
  double? get bmi {
    if (height == null || weight == null) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Check if blood sugar is normal (70-100 mg/dL fasting)
  bool? get isBloodSugarNormal {
    if (bloodSugar == null) return null;
    return bloodSugar! >= 70 && bloodSugar! <= 100;
  }

  /// Check if oxygen saturation is normal (95-100%)
  bool? get isOxygenSaturationNormal {
    if (oxygenSaturation == null) return null;
    return oxygenSaturation! >= 95 && oxygenSaturation! <= 100;
  }

  /// Get list of abnormal readings
  List<String> get abnormalReadings {
    final abnormal = <String>[];

    if (isBloodPressureNormal == false) {
      abnormal.add('Blood Pressure');
    }
    if (isHeartRateNormal == false) {
      abnormal.add('Heart Rate');
    }
    if (isTemperatureNormal == false) {
      abnormal.add('Temperature');
    }
    if (isBloodSugarNormal == false) {
      abnormal.add('Blood Sugar');
    }
    if (isOxygenSaturationNormal == false) {
      abnormal.add('Oxygen Saturation');
    }

    return abnormal;
  }

  /// Create Vitals from JSON
  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      id: json['id'] as String,
      userId: json['userId'] as String,
      familyMemberId: json['familyMemberId'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      bloodPressureSystolic: json['bloodPressureSystolic']?.toDouble(),
      bloodPressureDiastolic: json['bloodPressureDiastolic']?.toDouble(),
      heartRate: json['heartRate']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      bloodSugar: json['bloodSugar']?.toDouble(),
      oxygenSaturation: json['oxygenSaturation']?.toDouble(),
      notes: json['notes'] as String?,
      additionalMeasurements:
          json['additionalMeasurements'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Vitals to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'familyMemberId': familyMemberId,
      'recordedAt': recordedAt.toIso8601String(),
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'heartRate': heartRate,
      'temperature': temperature,
      'weight': weight,
      'height': height,
      'bloodSugar': bloodSugar,
      'oxygenSaturation': oxygenSaturation,
      'notes': notes,
      'additionalMeasurements': additionalMeasurements,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Vitals copyWith({
    String? id,
    String? userId,
    String? familyMemberId,
    DateTime? recordedAt,
    double? bloodPressureSystolic,
    double? bloodPressureDiastolic,
    double? heartRate,
    double? temperature,
    double? weight,
    double? height,
    double? bloodSugar,
    double? oxygenSaturation,
    String? notes,
    Map<String, dynamic>? additionalMeasurements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vitals(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      recordedAt: recordedAt ?? this.recordedAt,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      heartRate: heartRate ?? this.heartRate,
      temperature: temperature ?? this.temperature,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      notes: notes ?? this.notes,
      additionalMeasurements:
          additionalMeasurements ?? this.additionalMeasurements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vitals && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Vitals(id: $id, recordedAt: $recordedAt)';
  }
}
