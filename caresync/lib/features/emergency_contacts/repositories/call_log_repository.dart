import 'package:hive_flutter/hive_flutter.dart';
import '../models/call_log.dart';

class CallLogRepository {
  static const String _boxName = 'emergency_call_logs';
  Box<CallLog>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(CallLogAdapter());
    }
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<CallLog>(_boxName);
    }
  }

  Future<void> addCallLog(CallLog log) async {
    await init();
    await _box!.put(log.id, log);
  }

  List<CallLog> getAllLogs() {
    if (_box == null || !_box!.isOpen) return [];
    final logs = _box!.values.toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  List<CallLog> getRecentLogs({int limit = 10}) {
    final allLogs = getAllLogs();
    return allLogs.take(limit).toList();
  }

  List<CallLog> getLogsByContactId(String contactId) {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.where((log) => log.contactId == contactId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteLog(String logId) async {
    await init();
    await _box!.delete(logId);
  }

  Future<void> clear() async {
    await init();
    await _box!.clear();
  }

  int getCallCount(String contactId) {
    if (_box == null || !_box!.isOpen) return 0;
    return _box!.values.where((log) => log.contactId == contactId).length;
  }

  DateTime? getLastCallTime(String contactId) {
    final logs = getLogsByContactId(contactId);
    return logs.isEmpty ? null : logs.first.timestamp;
  }
}
