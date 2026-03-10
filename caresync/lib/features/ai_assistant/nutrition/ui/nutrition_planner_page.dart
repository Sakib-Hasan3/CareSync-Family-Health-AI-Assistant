import 'package:flutter/material.dart';
import '../../../family_profiles/family_repository.dart';
import '../../../family_profiles/models/family_member_model.dart';
import '../nutrition_service.dart';
import '../models/nutrition_profile.dart';

class NutritionPlannerPage extends StatefulWidget {
  const NutritionPlannerPage({super.key});

  @override
  State<NutritionPlannerPage> createState() => _NutritionPlannerPageState();
}

class _NutritionPlannerPageState extends State<NutritionPlannerPage> {
  final _familyRepo = FamilyRepository();
  List<FamilyMember> _members = [];
  FamilyMember? _selected;
  NutritionProfile? _profile;
  List<DailyPlan> _plan = [];
  int _waterDrank = 0; // ml

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    await _familyRepo.init();
    final m = _familyRepo.getAll();
    setState(() => _members = m);
  }

  void _buildProfileFromMember(FamilyMember m) {
    final p = NutritionProfile(
      id: m.id,
      memberId: m.id,
      age: 30,
      weightKg: 70,
      heightCm: 170,
      gender: 'male',
      diseases: m.chronicDiseases,
      allergies: m.allergies,
      goal: 'maintain',
    );
    setState(() {
      _selected = m;
      _profile = p;
      _plan = NutritionService().generateWeeklyPlan(p);
      _waterDrank = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Planner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Family Member',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<FamilyMember>(
              value: _selected,
              hint: const Text('Choose member'),
              items: _members
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                  .toList(),
              onChanged: (m) {
                if (m != null) _buildProfileFromMember(m);
              },
            ),
            const SizedBox(height: 16),
            if (_profile != null) ...[
              Text(
                'Daily target: ${NutritionService().targetCalories(_profile!)} kcal',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Water goal: ${NutritionService().waterGoalMl(_profile!)} ml',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              _buildWaterTracker(),
              const SizedBox(height: 12),
              Expanded(child: _buildWeeklyPlan()),
            ] else
              const Expanded(
                child: Center(child: Text('Select a member to generate plan')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTracker() {
    final goal = _profile == null
        ? 2000
        : NutritionService().waterGoalMl(_profile!);
    final pct = (_waterDrank / goal).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: pct, minHeight: 12),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('$_waterDrank ml of $goal ml'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => setState(() => _waterDrank += 250),
              child: const Text('+250 ml'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => setState(() => _waterDrank = 0),
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyPlan() {
    return ListView.builder(
      itemCount: _plan.length,
      itemBuilder: (context, idx) {
        final day = _plan[idx];
        final cals = NutritionService().estimateCaloriesForDay(day);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      day.day,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text('$cals kcal'),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Breakfast: ${day.breakfast.name}'),
                Text('Lunch: ${day.lunch.name}'),
                Text('Dinner: ${day.dinner.name}'),
                Text('Snack: ${day.snack.name}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
