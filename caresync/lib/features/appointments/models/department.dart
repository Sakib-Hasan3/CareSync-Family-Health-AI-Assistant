class Department {
  final String id;
  final String name;
  final String description;
  final String iconName; // for simple icon mapping

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
  });

  static List<Department> sampleDepartments() => [
    Department(
      id: 'cardiology',
      name: 'Cardiology',
      description: 'Heart specialists and cardiovascular care',
      iconName: 'heart',
    ),
    Department(
      id: 'dermatology',
      name: 'Dermatology',
      description: 'Skin-related consultations and care',
      iconName: 'skin',
    ),
    Department(
      id: 'general',
      name: 'General Medicine',
      description: 'General practitioners for common illnesses',
      iconName: 'stethoscope',
    ),
  ];
}
