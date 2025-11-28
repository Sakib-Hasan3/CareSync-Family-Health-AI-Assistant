import 'package:flutter/material.dart';
import 'models/emergency_contact.dart';

class EmergencyContactsData {
  static List<EmergencyContact> getDefaultContacts() {
    return [
      EmergencyContact(
        id: '1',
        name: 'National Emergency',
        number: '999',
        type: EmergencyContactType.ambulance,
        description: 'National emergency hotline for immediate assistance',
        icon: Icons.local_hospital_rounded,
        color: const Color(0xFFDC143C),
        isAvailable24x7: true,
        additionalInfo: 'Available nationwide',
      ),
      EmergencyContact(
        id: '2',
        name: 'Ambulance Service',
        number: '102',
        type: EmergencyContactType.ambulance,
        description: 'Free ambulance service across the country',
        icon: Icons.emergency_rounded,
        color: const Color(0xFFE91E63),
        isAvailable24x7: true,
        additionalInfo: 'Government ambulance service',
      ),
      EmergencyContact(
        id: '3',
        name: 'Police Emergency',
        number: '100',
        type: EmergencyContactType.police,
        description: 'Police emergency helpline',
        icon: Icons.local_police_rounded,
        color: const Color(0xFF1976D2),
        isAvailable24x7: true,
      ),
      EmergencyContact(
        id: '4',
        name: 'Fire Service',
        number: '101',
        type: EmergencyContactType.fire,
        description: 'Fire emergency and rescue services',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFFF5722),
        isAvailable24x7: true,
      ),
      EmergencyContact(
        id: '5',
        name: 'Women Helpline',
        number: '1091',
        type: EmergencyContactType.womenHelpline,
        description: '24/7 helpline for women in distress',
        icon: Icons.woman_rounded,
        color: const Color(0xFF9C27B0),
        isAvailable24x7: true,
        additionalInfo: 'Confidential support available',
      ),
      EmergencyContact(
        id: '6',
        name: 'Child Helpline',
        number: '1098',
        type: EmergencyContactType.childHelpline,
        description: 'Child protection and support services',
        icon: Icons.child_care_rounded,
        color: const Color(0xFF00BCD4),
        isAvailable24x7: true,
        additionalInfo: 'For children in need',
      ),
      EmergencyContact(
        id: '7',
        name: 'National Health Helpline',
        number: '104',
        type: EmergencyContactType.hospital,
        description: 'Medical advice and health information',
        icon: Icons.medical_services_rounded,
        color: const Color(0xFF4CAF50),
        isAvailable24x7: true,
        additionalInfo: 'Free medical consultation',
      ),
      EmergencyContact(
        id: '8',
        name: 'Mental Health Helpline',
        number: '1800-599-0019',
        type: EmergencyContactType.mentalHealth,
        description: 'Emotional support and mental health crisis line',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF673AB7),
        isAvailable24x7: true,
        additionalInfo: 'Confidential counseling',
      ),
      EmergencyContact(
        id: '9',
        name: 'Poison Control Center',
        number: '1800-102-9099',
        type: EmergencyContactType.poisonControl,
        description: 'Emergency guidance for poisoning cases',
        icon: Icons.dangerous_rounded,
        color: const Color(0xFFFF9800),
        isAvailable24x7: true,
      ),
      EmergencyContact(
        id: '10',
        name: 'Disaster Management',
        number: '108',
        type: EmergencyContactType.disasterManagement,
        description: 'Natural disaster and emergency response',
        icon: Icons.warning_rounded,
        color: const Color(0xFFF44336),
        isAvailable24x7: true,
        additionalInfo: 'NDRF emergency response',
      ),
      EmergencyContact(
        id: '11',
        name: 'Blood Bank',
        number: '1910',
        type: EmergencyContactType.hospital,
        description: 'Find blood donors and blood banks',
        icon: Icons.bloodtype_rounded,
        color: const Color(0xFFDC143C),
        isAvailable24x7: true,
        additionalInfo: 'Blood donation helpline',
      ),
      EmergencyContact(
        id: '12',
        name: 'COVID-19 Helpline',
        number: '1075',
        type: EmergencyContactType.hospital,
        description: 'COVID-19 related queries and support',
        icon: Icons.coronavirus_rounded,
        color: const Color(0xFF607D8B),
        isAvailable24x7: true,
      ),
      EmergencyContact(
        id: '13',
        name: 'Senior Citizen Helpline',
        number: '14567',
        type: EmergencyContactType.other,
        description: 'Support services for elderly citizens',
        icon: Icons.elderly_rounded,
        color: const Color(0xFF795548),
        isAvailable24x7: true,
        additionalInfo: 'Elder care assistance',
      ),
      EmergencyContact(
        id: '14',
        name: 'Road Accident Emergency',
        number: '1073',
        type: EmergencyContactType.ambulance,
        description: 'Emergency response for road accidents',
        icon: Icons.car_crash_rounded,
        color: const Color(0xFFE91E63),
        isAvailable24x7: true,
      ),
    ];
  }

  static List<EmergencyContact> filterByType(
    List<EmergencyContact> contacts,
    EmergencyContactType type,
  ) {
    return contacts.where((c) => c.type == type).toList();
  }

  static List<EmergencyContact> search(
    List<EmergencyContact> contacts,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();
    return contacts.where((c) {
      return c.name.toLowerCase().contains(lowerQuery) ||
          c.description.toLowerCase().contains(lowerQuery) ||
          c.number.contains(query) ||
          c.typeLabel.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
