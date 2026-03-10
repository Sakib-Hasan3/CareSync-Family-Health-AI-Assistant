class NutritionProfile {
  final String id;
  final String memberId; // family member id
  final int age;
  final double weightKg;
  final double heightCm;
  final String gender; // 'male'|'female'|other
  final List<String> diseases; // diabetes, hypertension, obesity, etc.
  final List<String> allergies; // ingredient names
  final String goal; // 'lose'|'maintain'|'gain'

  NutritionProfile({
    required this.id,
    required this.memberId,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    this.gender = 'male',
    this.diseases = const [],
    this.allergies = const [],
    this.goal = 'maintain',
  });
}
