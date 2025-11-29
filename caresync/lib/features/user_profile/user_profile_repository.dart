import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'models/user_profile.dart';

class UserProfileRepository {
  static const String boxName = 'user_profile_box';
  static bool _isInitialized = false;

  // Singleton instance
  static final UserProfileRepository _instance =
      UserProfileRepository._internal();
  factory UserProfileRepository() => _instance;
  UserProfileRepository._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(UserProfileAdapter());
      }

      await Hive.openBox<UserProfile>(boxName);
      _isInitialized = true;
      print('UserProfileRepository initialized successfully');
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize UserProfileRepository: $e');
    }
  }

  Box<UserProfile> get _box {
    if (!_isInitialized) {
      throw Exception(
          'UserProfileRepository not initialized. Call init() first.');
    }
    return Hive.box<UserProfile>(boxName);
  }

  /// Get current user profile or create a default one from Firebase user
  Future<UserProfile> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    // Try to get existing profile
    final existing = _box.get('current_user');
    if (existing != null) {
      return existing;
    }

    // Create default profile from Firebase user
    final defaultProfile = UserProfile(
      id: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      phone: user.phoneNumber,
      photoUrl: user.photoURL,
    );

    await saveProfile(defaultProfile);
    return defaultProfile;
  }

  /// Save or update user profile
  Future<void> saveProfile(UserProfile profile) async {
    await _box.put('current_user', profile);
    print('User profile saved successfully');
  }

  /// Update specific fields of the profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? address,
    List<String>? allergies,
    List<String>? chronicDiseases,
    List<String>? medications,
    String? emergencyContact,
    String? emergencyContactName,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    double? height,
    double? weight,
  }) async {
    final current = await getCurrentUserProfile();
    final updated = current.copyWith(
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
      bloodGroup: bloodGroup,
      address: address,
      allergies: allergies,
      chronicDiseases: chronicDiseases,
      medications: medications,
      emergencyContact: emergencyContact,
      emergencyContactName: emergencyContactName,
      insuranceProvider: insuranceProvider,
      insurancePolicyNumber: insurancePolicyNumber,
      height: height,
      weight: weight,
    );
    await saveProfile(updated);
  }

  /// Delete user profile
  Future<void> deleteProfile() async {
    await _box.delete('current_user');
    print('User profile deleted');
  }

  /// Clear all data
  Future<void> clear() async {
    await _box.clear();
    print('User profile repository cleared');
  }

  /// Close the repository
  Future<void> close() async {
    try {
      await _box.close();
      _isInitialized = false;
      print('UserProfileRepository closed successfully');
    } catch (e) {
      print('Error closing UserProfileRepository: $e');
    }
  }
}
