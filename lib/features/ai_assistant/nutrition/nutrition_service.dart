import 'dart:math';
import 'models/nutrition_profile.dart';

class MealItem {
  final String name;
  final int calories;
  final List<String> ingredients;

  MealItem(this.name, this.calories, [this.ingredients = const []]);
}

class DailyPlan {
  final String day;
  final MealItem breakfast;
  final MealItem lunch;
  final MealItem dinner;
  final MealItem snack;

  DailyPlan({
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
  });
}

class NutritionService {
  static final NutritionService _instance = NutritionService._internal();
  factory NutritionService() => _instance;
  NutritionService._internal();

  /// Simple BMR (Mifflin-St Jeor) kcal/day estimate
  double estimateBmr(NutritionProfile p) {
    final weight = p.weightKg;
    final height = p.heightCm;
    final age = p.age.toDouble();
    if (p.gender.toLowerCase() == 'female') {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
    return 10 * weight + 6.25 * height - 5 * age + 5;
  }

  /// Target calories with activity multiplier (sedentary default)
  int targetCalories(NutritionProfile p, {String activity = 'sedentary'}) {
    final bmr = estimateBmr(p);
    final mult = activity == 'active' ? 1.4 : 1.2;
    double target = bmr * mult;
    if (p.goal == 'lose') target -= 500;
    if (p.goal == 'gain') target += 300;
    return max(1200, target.round());
  }

  /// Generate a simple weekly plan (7 days) given a profile.
  List<DailyPlan> generateWeeklyPlan(NutritionProfile p) {
    // small internal meal pool
    final pool = <MealItem>[
      MealItem('Oatmeal with fruit', 350, ['oats', 'milk', 'banana']),
      MealItem('Greek yogurt + berries', 220, ['yogurt', 'berries']),
      MealItem('Grilled chicken salad', 420, ['chicken', 'lettuce', 'tomato']),
      MealItem('Brown rice & veggies', 480, ['rice', 'broccoli', 'carrot']),
      MealItem('Lentil soup', 300, ['lentils', 'onion', 'garlic']),
      MealItem('Steamed fish & greens', 430, ['fish', 'spinach']),
      MealItem('Quinoa salad', 380, ['quinoa', 'cucumber', 'tomato']),
      MealItem('Fruit smoothie', 250, ['milk', 'banana', 'berries']),
      MealItem('Nut & seed snack', 180, ['almonds', 'walnuts']),
    ];

    // filter pool for allergies and diseases
    final filtered = pool.where((m) {
      for (final a in p.allergies) {
        for (final ing in m.ingredients) {
          if (ing.toLowerCase().contains(a.toLowerCase())) return false;
        }
      }
      // simple disease rules: diabetes -> avoid high sugar fruits/smoothies
      if (p.diseases.any((d) => d.toLowerCase().contains('diabet'))) {
        if (m.name.toLowerCase().contains('smoothie') ||
            m.name.toLowerCase().contains('fruit'))
          return false;
      }
      // hypertension -> prefer low-salt (we can't check salt explicitly here)
      return true;
    }).toList();

    // if nothing left fall back
    final finalPool = filtered.isNotEmpty ? filtered : pool;

    final rng = Random(p.id.hashCode);
    final days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final plans = <DailyPlan>[];
    for (final d in days) {
      final b = finalPool[rng.nextInt(finalPool.length)];
      final l = finalPool[rng.nextInt(finalPool.length)];
      final di = finalPool[rng.nextInt(finalPool.length)];
      final s = finalPool[rng.nextInt(finalPool.length)];
      plans.add(
        DailyPlan(day: d, breakfast: b, lunch: l, dinner: di, snack: s),
      );
    }
    return plans;
  }

  /// Simple water goal based on weight: 35 ml per kg
  int waterGoalMl(NutritionProfile p) => (p.weightKg * 35).round();

  /// Calorie estimation for a meallist
  int estimateCaloriesForDay(DailyPlan day) =>
      day.breakfast.calories +
      day.lunch.calories +
      day.dinner.calories +
      day.snack.calories;
}
