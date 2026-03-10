import 'department.dart';

class Facility {
  final String id;
  final String name;
  final String location; // human-readable address/city
  final List<Department> departments;

  Facility({
    required this.id,
    required this.name,
    required this.location,
    required this.departments,
  });

  static List<Facility> sampleFacilitiesForDivision(String divisionId) {
    // For demo purposes we return 3 facilities per division with sample departments
    final deps = Department.sampleDepartments();
    return List.generate(3, (i) {
      return Facility(
        id: '$divisionId-fac-${i + 1}',
        name: '${divisionId.toUpperCase()} Medical Center ${i + 1}',
        location: '${divisionId.toUpperCase()} City — Block ${i + 2}',
        departments: deps,
      );
    });
  }
}
