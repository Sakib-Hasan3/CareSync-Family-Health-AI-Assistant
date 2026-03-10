class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String clinic;
  final String? photoUrl;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.clinic,
    this.photoUrl,
  });
}

// Sample doctors for demo purposes
const sampleDoctors = [
  Doctor(
    id: 'd1',
    name: 'Dr. Aisha Rahman',
    specialty: 'Cardiologist',
    clinic: 'City Heart Clinic',
    photoUrl: null,
  ),
  Doctor(
    id: 'd2',
    name: 'Dr. Imran Hossain',
    specialty: 'General Physician',
    clinic: 'Green Clinic',
    photoUrl: null,
  ),
  Doctor(
    id: 'd3',
    name: 'Dr. Sumi Begum',
    specialty: 'Pediatrician',
    clinic: 'Sunrise Kids',
    photoUrl: null,
  ),
];
