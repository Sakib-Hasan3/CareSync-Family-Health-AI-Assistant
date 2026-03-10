import 'package:hive/hive.dart';
import 'models/family_member_model.dart';

class FamilyRepository {
  static const String boxName = 'family_members_box';
  static bool _isInitialized = false;

  // Singleton instance
  static final FamilyRepository _instance = FamilyRepository._internal();
  factory FamilyRepository() => _instance;
  FamilyRepository._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(FamilyMemberAdapter());
      }

      await Hive.openBox<FamilyMember>(boxName);
      _isInitialized = true;
      print('FamilyRepository initialized successfully');
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize FamilyRepository: $e');
    }
  }

  Box<FamilyMember> get _box {
    if (!_isInitialized) {
      throw Exception('FamilyRepository not initialized. Call init() first.');
    }
    return Hive.box<FamilyMember>(boxName);
  }

  /// Get all family members sorted by name
  List<FamilyMember> getAll() {
    try {
      final members = _box.values.toList();
      members.sort((a, b) => a.name.compareTo(b.name));
      return members;
    } catch (e) {
      print('Error getting all family members: $e');
      return [];
    }
  }

  /// Get all family members with optional filtering
  List<FamilyMember> getAllWhere(bool Function(FamilyMember) test) {
    try {
      return _box.values.where(test).toList();
    } catch (e) {
      print('Error getting filtered family members: $e');
      return [];
    }
  }

  /// Add or update a family member
  Future<void> addOrUpdate(FamilyMember member) async {
    try {
      // Validate member data
      if (member.name.trim().isEmpty) {
        throw Exception('Family member name cannot be empty');
      }

      await _box.put(member.id, member);
      print('Family member ${member.name} saved successfully');
    } catch (e) {
      print('Error saving family member: $e');
      rethrow;
    }
  }

  /// Delete a family member by ID
  Future<void> delete(String id) async {
    try {
      final member = _box.get(id);
      if (member != null) {
        await _box.delete(id);
        print('Family member ${member.name} deleted successfully');
      }
    } catch (e) {
      print('Error deleting family member: $e');
      rethrow;
    }
  }

  /// Delete multiple family members
  Future<void> deleteMultiple(List<String> ids) async {
    try {
      await _box.deleteAll(ids);
      print('${ids.length} family members deleted successfully');
    } catch (e) {
      print('Error deleting multiple family members: $e');
      rethrow;
    }
  }

  /// Get family member by ID
  FamilyMember? getById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      print('Error getting family member by ID: $e');
      return null;
    }
  }

  /// Check if a family member exists
  bool exists(String id) {
    try {
      return _box.containsKey(id);
    } catch (e) {
      print('Error checking if family member exists: $e');
      return false;
    }
  }

  /// Get total count of family members
  int get count {
    try {
      return _box.length;
    } catch (e) {
      print('Error getting family members count: $e');
      return 0;
    }
  }

  /// Search family members by name
  List<FamilyMember> searchByName(String query) {
    try {
      if (query.isEmpty) return getAll();

      final lowerQuery = query.toLowerCase();
      return _box.values
          .where((member) => member.name.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      print('Error searching family members: $e');
      return [];
    }
  }

  /// Get family members with specific blood group
  List<FamilyMember> getByBloodGroup(String bloodGroup) {
    try {
      return _box.values
          .where(
            (member) =>
                member.bloodGroup.toLowerCase() == bloodGroup.toLowerCase(),
          )
          .toList();
    } catch (e) {
      print('Error getting family members by blood group: $e');
      return [];
    }
  }

  /// Get family members with allergies
  List<FamilyMember> getWithAllergies() {
    try {
      return _box.values
          .where((member) => member.allergies.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error getting family members with allergies: $e');
      return [];
    }
  }

  /// Get family members with chronic diseases
  List<FamilyMember> getWithChronicDiseases() {
    try {
      return _box.values
          .where((member) => member.chronicDiseases.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error getting family members with chronic diseases: $e');
      return [];
    }
  }

  /// Clear all family members
  Future<void> clearAll() async {
    try {
      await _box.clear();
      print('All family members cleared successfully');
    } catch (e) {
      print('Error clearing all family members: $e');
      rethrow;
    }
  }

  /// Get statistics about family members
  Map<String, dynamic> getStatistics() {
    try {
      final members = _box.values.toList();
      final totalMembers = members.length;

      final bloodGroups = <String, int>{};
      final totalAllergies = members.fold(
        0,
        (sum, member) => sum + member.allergies.length,
      );
      final totalConditions = members.fold(
        0,
        (sum, member) => sum + member.chronicDiseases.length,
      );
      final totalMedications = members.fold(
        0,
        (sum, member) => sum + member.medications.length,
      );

      for (final member in members) {
        if (member.bloodGroup.isNotEmpty) {
          bloodGroups[member.bloodGroup] =
              (bloodGroups[member.bloodGroup] ?? 0) + 1;
        }
      }

      return {
        'totalMembers': totalMembers,
        'bloodGroups': bloodGroups,
        'totalAllergies': totalAllergies,
        'totalConditions': totalConditions,
        'totalMedications': totalMedications,
        'membersWithAllergies': getWithAllergies().length,
        'membersWithConditions': getWithChronicDiseases().length,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  /// Export all family members data (for backup purposes)
  List<Map<String, dynamic>> exportData() {
    try {
      return _box.values.map((member) => member.toJson()).toList();
    } catch (e) {
      print('Error exporting family data: $e');
      return [];
    }
  }

  /// Import family members data (for restore purposes)
  Future<void> importData(List<Map<String, dynamic>> data) async {
    try {
      for (final item in data) {
        final member = FamilyMember.fromJson(item);
        await addOrUpdate(member);
      }
      print('${data.length} family members imported successfully');
    } catch (e) {
      print('Error importing family data: $e');
      rethrow;
    }
  }

  /// Close the Hive box (call when app is closing)
  Future<void> close() async {
    try {
      await _box.close();
      _isInitialized = false;
      print('FamilyRepository closed successfully');
    } catch (e) {
      print('Error closing FamilyRepository: $e');
    }
  }

  /// Dispose the repository (for testing or app termination)
  Future<void> dispose() async {
    await close();
  }
}
