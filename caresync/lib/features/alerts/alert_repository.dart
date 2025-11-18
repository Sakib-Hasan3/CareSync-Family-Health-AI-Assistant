import 'package:hive/hive.dart';
import 'models/smart_alert.dart';

class AlertRepository {
  static const String boxName = 'smart_alerts_box';
  static final AlertRepository _instance = AlertRepository._internal();
  factory AlertRepository() => _instance;
  AlertRepository._internal();

  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    if (!Hive.isAdapterRegistered(203))
      Hive.registerAdapter(SmartAlertAdapter());
    await Hive.openBox<SmartAlert>(boxName);
    _inited = true;
  }

  Box<SmartAlert> get _box {
    if (!_inited) throw Exception('AlertRepository not initialized');
    return Hive.box<SmartAlert>(boxName);
  }

  List<SmartAlert> getAll() => _box.values.toList().reversed.toList();

  Future<void> add(SmartAlert a) async => await _box.put(a.id, a);

  Future<void> remove(String id) async => await _box.delete(id);

  Future<void> ack(String id) async {
    final a = _box.get(id);
    if (a != null) {
      a.acknowledged = true;
      await _box.put(id, a);
    }
  }
}
