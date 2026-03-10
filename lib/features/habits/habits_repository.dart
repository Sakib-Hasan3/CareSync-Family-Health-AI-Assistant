import 'package:hive/hive.dart';
import 'models/habit_entry.dart';

class HabitsRepository {
  static const _boxName = 'habits_box';
  static bool _initialized = false;
  static final _instance = HabitsRepository._();
  factory HabitsRepository() => _instance;
  HabitsRepository._();

  Future<void> init() async {
    if (_initialized) return;
    if (!Hive.isAdapterRegistered(222)) {
      Hive.registerAdapter(HabitEntryAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<HabitEntry>(_boxName);
    }
    _initialized = true;
  }

  Box<HabitEntry> get _box => Hive.box<HabitEntry>(_boxName);

  HabitEntry getForDate(DateTime date) {
    final key = _key(date);
    return _box.get(key) ?? HabitEntry(id: key);
  }

  Future<void> save(HabitEntry entry) => _box.put(entry.id, entry);

  List<HabitEntry> getWeekly({int daysBack = 7}) {
    final result = <HabitEntry>[];
    for (int i = daysBack - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      result.add(getForDate(date));
    }
    return result;
  }

  int getStreak() {
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final entry = _box.get(_key(date));
      final hasData = entry != null &&
          (entry.waterGlasses > 0 ||
              entry.steps > 0 ||
              entry.sleepHours > 0 ||
              entry.exerciseMinutes > 0 ||
              entry.mood > 0);
      if (hasData) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
