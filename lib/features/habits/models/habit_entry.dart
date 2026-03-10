import 'package:hive/hive.dart';

/// Hive model for a single day's habits entry. typeId = 222
/// The [id] is the date string in 'yyyy-MM-dd' format (one entry per day).
class HabitEntry {
  String id; // yyyy-MM-dd
  int waterGlasses; // 0-12
  int steps; // manual entry
  double sleepHours; // 0.0-12.0
  int exerciseMinutes;
  int mood; // 1=terrible, 2=bad, 3=ok, 4=good, 5=great
  int meditationMinutes;
  String notes;

  HabitEntry({
    required this.id,
    this.waterGlasses = 0,
    this.steps = 0,
    this.sleepHours = 0,
    this.exerciseMinutes = 0,
    this.mood = 0,
    this.meditationMinutes = 0,
    this.notes = '',
  });

  /// Percentage of defined goals completed (0.0 – 1.0).
  double get completionRate {
    int done = 0;
    if (waterGlasses >= 8) done++;
    if (steps >= 5000) done++;
    if (sleepHours >= 6) done++;
    if (exerciseMinutes >= 20) done++;
    if (mood > 0) done++;
    return done / 5;
  }
}

class HabitEntryAdapter extends TypeAdapter<HabitEntry> {
  @override
  final int typeId = 222;

  @override
  HabitEntry read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return HabitEntry(
      id: f[0] as String,
      waterGlasses: f[1] as int? ?? 0,
      steps: f[2] as int? ?? 0,
      sleepHours: f[3] as double? ?? 0,
      exerciseMinutes: f[4] as int? ?? 0,
      mood: f[5] as int? ?? 0,
      meditationMinutes: f[6] as int? ?? 0,
      notes: f[7] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, HabitEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.waterGlasses)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.sleepHours)
      ..writeByte(4)
      ..write(obj.exerciseMinutes)
      ..writeByte(5)
      ..write(obj.mood)
      ..writeByte(6)
      ..write(obj.meditationMinutes)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntryAdapter && typeId == other.typeId;
}
