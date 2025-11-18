import 'package:cloud_firestore/cloud_firestore.dart';

class Division {
  final String id;
  final String name;
  Division({required this.id, required this.name});
  factory Division.fromMap(String id, Map<String, dynamic> m) =>
      Division(id: id, name: (m['name'] as String?) ?? '');
  Map<String, dynamic> toMap() => {'name': name};

  // Ensure two Division instances with the same id are considered equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Division && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Division(id: $id, name: $name)';
}

class District {
  final String id;
  final String divisionId;
  final String name;
  District({required this.id, required this.divisionId, required this.name});
  factory District.fromMap(String id, Map<String, dynamic> m) => District(
    id: id,
    divisionId: (m['divisionId'] as String?) ?? '',
    name: (m['name'] as String?) ?? '',
  );
  Map<String, dynamic> toMap() => {'divisionId': divisionId, 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is District && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'District(id: $id, divisionId: $divisionId, name: $name)';
}

class MedicalCenter {
  final String id;
  final String divisionId;
  final String districtId;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  MedicalCenter({
    required this.id,
    required this.divisionId,
    required this.districtId,
    required this.name,
    required this.address,
    this.phone,
    this.email,
  });
  factory MedicalCenter.fromMap(String id, Map<String, dynamic> m) =>
      MedicalCenter(
        id: id,
        divisionId: (m['divisionId'] as String?) ?? '',
        districtId: (m['districtId'] as String?) ?? '',
        name: (m['name'] as String?) ?? '',
        address: (m['address'] as String?) ?? '',
        phone: m['phone'] as String?,
        email: m['email'] as String?,
      );
  Map<String, dynamic> toMap() => {
    'divisionId': divisionId,
    'districtId': districtId,
    'name': name,
    'address': address,
    'phone': phone,
    'email': email,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MedicalCenter && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MedicalCenter(id: $id, divisionId: $divisionId, districtId: $districtId, name: $name)';
}

class DoctorProfile {
  final String id;
  final String centerId;
  final String fullName;
  final String specialization;
  final String? phone;
  final String? email;
  DoctorProfile({
    required this.id,
    required this.centerId,
    required this.fullName,
    required this.specialization,
    this.phone,
    this.email,
  });
  factory DoctorProfile.fromMap(String id, Map<String, dynamic> m) =>
      DoctorProfile(
        id: id,
        centerId: (m['centerId'] as String?) ?? '',
        fullName: (m['fullName'] as String?) ?? '',
        specialization: (m['specialization'] as String?) ?? '',
        phone: m['phone'] as String?,
        email: m['email'] as String?,
      );
  Map<String, dynamic> toMap() => {
    'centerId': centerId,
    'fullName': fullName,
    'specialization': specialization,
    'phone': phone,
    'email': email,
  };
}

class DutySlot {
  final int weekday; // 1=Mon..7=Sun
  final String start; // HH:mm
  final String end; // HH:mm
  DutySlot({required this.weekday, required this.start, required this.end});
  factory DutySlot.fromMap(Map<String, dynamic> m) => DutySlot(
    weekday: (m['weekday'] as num?)?.toInt() ?? 1,
    start: (m['start'] as String?) ?? '09:00',
    end: (m['end'] as String?) ?? '17:00',
  );
  Map<String, dynamic> toMap() => {
    'weekday': weekday,
    'start': start,
    'end': end,
  };
}

class DutySchedule {
  final String id;
  final String doctorId;
  final List<DutySlot> slots;
  DutySchedule({required this.id, required this.doctorId, required this.slots});
  factory DutySchedule.fromMap(String id, Map<String, dynamic> m) =>
      DutySchedule(
        id: id,
        doctorId: (m['doctorId'] as String?) ?? '',
        slots: (m['slots'] as List<dynamic>? ?? [])
            .map((e) => DutySlot.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
  Map<String, dynamic> toMap() => {
    'doctorId': doctorId,
    'slots': slots.map((e) => e.toMap()).toList(),
  };
}

class DirectoryRepository {
  final FirebaseFirestore _db;
  DirectoryRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _divisions =>
      _db.collection('divisions');
  CollectionReference<Map<String, dynamic>> get _districts =>
      _db.collection('districts');
  CollectionReference<Map<String, dynamic>> get _centers =>
      _db.collection('medical_centers');
  CollectionReference<Map<String, dynamic>> get _doctors =>
      _db.collection('doctors');
  CollectionReference<Map<String, dynamic>> get _schedules =>
      _db.collection('duty_schedules');

  Future<List<Division>> listDivisions() async {
    final snap = await _divisions.orderBy('name').get();
    return snap.docs.map((d) => Division.fromMap(d.id, d.data())).toList();
  }

  Future<List<District>> listDistricts(String divisionId) async {
    final snap = await _districts
        .where('divisionId', isEqualTo: divisionId)
        .get();
    final list = snap.docs
        .map((d) => District.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<List<MedicalCenter>> listCenters(
    String divisionId,
    String districtId,
  ) async {
    // Query by districtId only to avoid composite index requirements
    final q = _centers.where('districtId', isEqualTo: districtId);
    final snap = await q.get();
    final list = snap.docs
        .map((d) => MedicalCenter.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<List<DoctorProfile>> listDoctorsByCenter(String centerId) async {
    final snap = await _doctors.where('centerId', isEqualTo: centerId).get();
    final list = snap.docs
        .map((d) => DoctorProfile.fromMap(d.id, d.data()))
        .toList();
    list.sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
    return list;
  }

  Future<DutySchedule?> getSchedule(String doctorId) async {
    final snap = await _schedules
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final d = snap.docs.first;
    return DutySchedule.fromMap(d.id, d.data());
  }

  // Admin helpers (optional)
  Future<String> createDivision(String name) async {
    final doc = await _divisions.add({'name': name});
    return doc.id;
  }

  Future<String> createDistrict({
    required String divisionId,
    required String name,
  }) async {
    final doc = await _districts.add({'divisionId': divisionId, 'name': name});
    return doc.id;
  }

  Future<String> createCenter({
    required String divisionId,
    required String districtId,
    required String name,
    String address = '',
    String? phone,
    String? email,
  }) async {
    final doc = await _centers.add({
      'divisionId': divisionId,
      'districtId': districtId,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
    });
    return doc.id;
  }

  Future<String> createDoctor({
    required String centerId,
    required String fullName,
    required String specialization,
    String? phone,
    String? email,
  }) async {
    final doc = await _doctors.add({
      'centerId': centerId,
      'fullName': fullName,
      'specialization': specialization,
      'phone': phone,
      'email': email,
    });
    return doc.id;
  }

  Future<void> setSchedule({
    required String doctorId,
    required List<DutySlot> slots,
  }) async {
    final existing = await _schedules
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();
    final data = {
      'doctorId': doctorId,
      'slots': slots.map((e) => e.toMap()).toList(),
    };
    if (existing.docs.isEmpty) {
      await _schedules.add(data);
    } else {
      await existing.docs.first.reference.set(data);
    }
  }
}

class DutyHelper {
  static bool isOnDutyNow(DutySchedule schedule, {DateTime? now}) {
    final t = now ?? DateTime.now();
    final weekday = t.weekday; // 1..7
    final slots = schedule.slots.where((s) => s.weekday == weekday);
    final hm = t.hour * 60 + t.minute;
    for (final s in slots) {
      final start = _toMinutes(s.start);
      final end = _toMinutes(s.end);
      if (hm >= start && hm <= end) return true;
    }
    return false;
  }

  static List<DutySlot> upcomingSlots(DutySchedule schedule, {DateTime? from}) {
    final t = from ?? DateTime.now();
    final wd = t.weekday;
    final hm = t.hour * 60 + t.minute;
    final sameDay = schedule.slots
        .where((s) => s.weekday == wd && _toMinutes(s.start) > hm)
        .toList();
    if (sameDay.isNotEmpty)
      return sameDay..sort((a, b) => _toMinutes(a.start) - _toMinutes(b.start));
    // next days
    for (int i = 1; i <= 7; i++) {
      final day = (wd + i - 1) % 7 + 1;
      final list = schedule.slots.where((s) => s.weekday == day).toList();
      if (list.isNotEmpty)
        return list..sort((a, b) => _toMinutes(a.start) - _toMinutes(b.start));
    }
    return [];
  }

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }
}
