import 'models/donor.dart';
import 'donor_repository.dart';

/// Very simple matching service: matches by exact blood group and city.
class DonorMatchService {
  static final DonorMatchService _instance = DonorMatchService._internal();
  factory DonorMatchService() => _instance;
  DonorMatchService._internal();

  final DonorRepository _repo = DonorRepository();

  Future<void> _ensure() async {
    try {
      await _repo.init();
    } catch (_) {}
  }

  Future<List<Donor>> findMatches({
    required String bloodGroup,
    String? city,
    int limit = 10,
  }) async {
    await _ensure();
    final all = _repo.getAll();
    final candidates = all.where((d) {
      if (!d.available) return false;
      if (d.bloodGroup.toLowerCase() != bloodGroup.toLowerCase()) return false;
      if (city != null && city.trim().isNotEmpty) {
        return d.city.toLowerCase().contains(city.toLowerCase());
      }
      return true;
    }).toList();
    // Sort by recency of donation (prefer those who donated longer ago)
    candidates.sort((a, b) {
      final aLast = a.lastDonated ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bLast = b.lastDonated ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aLast.compareTo(bLast);
    });
    if (candidates.length <= limit) return candidates;
    return candidates.take(limit).toList();
  }
}
