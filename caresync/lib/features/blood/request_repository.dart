import 'package:hive/hive.dart';
import 'models/blood_request.dart';

class RequestRepository {
  static const String boxName = 'blood_requests_box';
  Box<BloodRequest>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(211))
      Hive.registerAdapter(BloodRequestAdapter());
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<BloodRequest>(boxName);
    } else {
      _box = await Hive.openBox<BloodRequest>(boxName);
    }
  }

  List<BloodRequest> getAll() => _box?.values.toList() ?? [];

  Future<void> add(BloodRequest r) async {
    if (_box == null) await init();
    await _box!.put(r.id, r);
  }

  Future<void> remove(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  BloodRequest? getById(String id) => _box?.get(id);
}
