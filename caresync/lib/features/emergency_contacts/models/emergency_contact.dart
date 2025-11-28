import 'package:flutter/material.dart';

enum EmergencyContactType {
  ambulance,
  hospital,
  police,
  fire,
  poisonControl,
  mentalHealth,
  disasterManagement,
  childHelpline,
  womenHelpline,
  other,
}

class EmergencyContact {
  final String id;
  final String name;
  final String number;
  final EmergencyContactType type;
  final String description;
  final IconData icon;
  final Color color;
  final bool isAvailable24x7;
  final String? additionalInfo;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.number,
    required this.type,
    required this.description,
    required this.icon,
    required this.color,
    this.isAvailable24x7 = true,
    this.additionalInfo,
  });

  String get typeLabel {
    switch (type) {
      case EmergencyContactType.ambulance:
        return 'Ambulance';
      case EmergencyContactType.hospital:
        return 'Hospital';
      case EmergencyContactType.police:
        return 'Police';
      case EmergencyContactType.fire:
        return 'Fire Service';
      case EmergencyContactType.poisonControl:
        return 'Poison Control';
      case EmergencyContactType.mentalHealth:
        return 'Mental Health';
      case EmergencyContactType.disasterManagement:
        return 'Disaster Management';
      case EmergencyContactType.childHelpline:
        return 'Child Helpline';
      case EmergencyContactType.womenHelpline:
        return 'Women Helpline';
      case EmergencyContactType.other:
        return 'Emergency';
    }
  }
}
