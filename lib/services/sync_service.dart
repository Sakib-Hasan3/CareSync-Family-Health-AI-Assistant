import 'dart:async';
import 'api_service.dart';
import 'local_storage_service.dart';

/// Sync status enum
enum SyncStatus { idle, syncing, success, error }

/// Sync result model
class SyncResult {
  final SyncStatus status;
  final String? message;
  final int? itemsSynced;
  final DateTime timestamp;

  SyncResult({
    required this.status,
    this.message,
    this.itemsSynced,
    required this.timestamp,
  });
}

/// Sync service for offline-to-online data synchronization
abstract class SyncService {
  Future<void> initialize();
  Future<SyncResult> syncAll();
  Future<SyncResult> syncMedications();
  Future<SyncResult> syncAppointments();
  Future<SyncResult> syncDocuments();
  Future<SyncResult> syncVitals();
  Future<SyncResult> syncProfiles();
  Future<void> enableAutoSync();
  Future<void> disableAutoSync();
  Stream<SyncStatus> get syncStatusStream;
  Future<bool> hasPendingChanges();
}

/// Implementation of sync service
class SyncServiceImpl implements SyncService {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  bool _initialized = false;
  bool _autoSyncEnabled = false;
  Timer? _autoSyncTimer;
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  SyncServiceImpl({
    required ApiService apiService,
    required LocalStorageService localStorage,
  }) : _apiService = apiService,
       _localStorage = localStorage;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    await _localStorage.initialize();
    _initialized = true;

    // Check if auto-sync was previously enabled
    final autoSyncEnabled =
        await _localStorage.getBool('auto_sync_enabled') ?? false;
    if (autoSyncEnabled) {
      await enableAutoSync();
    }
  }

  @override
  Future<SyncResult> syncAll() async {
    if (!_initialized) {
      throw Exception('SyncService not initialized');
    }

    _syncStatusController.add(SyncStatus.syncing);

    try {
      int totalItemsSynced = 0;
      final results = <SyncResult>[];

      // Sync all data types
      results.add(await syncMedications());
      results.add(await syncAppointments());
      results.add(await syncDocuments());
      results.add(await syncVitals());
      results.add(await syncProfiles());

      // Calculate total items synced
      for (final result in results) {
        if (result.itemsSynced != null) {
          totalItemsSynced += result.itemsSynced!;
        }
      }

      // Check if any sync failed
      final hasErrors = results.any(
        (result) => result.status == SyncStatus.error,
      );

      final finalResult = SyncResult(
        status: hasErrors ? SyncStatus.error : SyncStatus.success,
        message: hasErrors
            ? 'Some items failed to sync'
            : 'All data synced successfully',
        itemsSynced: totalItemsSynced,
        timestamp: DateTime.now(),
      );

      _syncStatusController.add(finalResult.status);
      await _updateLastSyncTime();

      return finalResult;
    } catch (e) {
      final errorResult = SyncResult(
        status: SyncStatus.error,
        message: 'Sync failed: ${e.toString()}',
        timestamp: DateTime.now(),
      );

      _syncStatusController.add(SyncStatus.error);
      return errorResult;
    }
  }

  @override
  Future<SyncResult> syncMedications() async {
    return await _syncDataType('medications', '/api/medications');
  }

  @override
  Future<SyncResult> syncAppointments() async {
    return await _syncDataType('appointments', '/api/appointments');
  }

  @override
  Future<SyncResult> syncDocuments() async {
    return await _syncDataType('documents', '/api/documents');
  }

  @override
  Future<SyncResult> syncVitals() async {
    return await _syncDataType('vitals', '/api/vitals');
  }

  @override
  Future<SyncResult> syncProfiles() async {
    return await _syncDataType('profiles', '/api/profiles');
  }

  /// Generic sync method for different data types
  Future<SyncResult> _syncDataType(String dataType, String endpoint) async {
    try {
      // Get pending changes from local storage
      final pendingChanges =
          await _localStorage.getObjectList('${dataType}_pending') ?? [];

      if (pendingChanges.isEmpty) {
        return SyncResult(
          status: SyncStatus.success,
          message: 'No pending changes for $dataType',
          itemsSynced: 0,
          timestamp: DateTime.now(),
        );
      }

      int syncedCount = 0;

      // Sync each pending change
      for (final change in pendingChanges) {
        try {
          final action = change['action'] as String;
          final data = change['data'] as Map<String, dynamic>;

          switch (action) {
            case 'create':
              await _apiService.post(endpoint, body: data);
              break;
            case 'update':
              await _apiService.put('$endpoint/${data['id']}', body: data);
              break;
            case 'delete':
              await _apiService.delete('$endpoint/${data['id']}');
              break;
          }

          syncedCount++;
        } catch (e) {
          // Log individual item sync failure but continue with others
          print('Failed to sync ${change['action']} for $dataType: $e');
        }
      }

      // Clear synced items from pending list
      if (syncedCount > 0) {
        await _localStorage.remove('${dataType}_pending');
      }

      return SyncResult(
        status: SyncStatus.success,
        message: 'Synced $syncedCount $dataType items',
        itemsSynced: syncedCount,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SyncResult(
        status: SyncStatus.error,
        message: 'Failed to sync $dataType: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<void> enableAutoSync() async {
    if (_autoSyncEnabled) return;

    _autoSyncEnabled = true;
    await _localStorage.saveBool('auto_sync_enabled', true);

    // Start periodic sync every 15 minutes
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      syncAll();
    });
  }

  @override
  Future<void> disableAutoSync() async {
    _autoSyncEnabled = false;
    await _localStorage.saveBool('auto_sync_enabled', false);

    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  @override
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  @override
  Future<bool> hasPendingChanges() async {
    final dataTypes = [
      'medications',
      'appointments',
      'documents',
      'vitals',
      'profiles',
    ];

    for (final dataType in dataTypes) {
      final pendingChanges = await _localStorage.getObjectList(
        '${dataType}_pending',
      );
      if (pendingChanges != null && pendingChanges.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  /// Add pending change to sync queue
  Future<void> addPendingChange(
    String dataType,
    String action,
    Map<String, dynamic> data,
  ) async {
    final pendingChanges =
        await _localStorage.getObjectList('${dataType}_pending') ?? [];

    pendingChanges.add({
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _localStorage.saveObjectList('${dataType}_pending', pendingChanges);
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final lastSyncString = await _localStorage.getString('last_sync_time');
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  /// Update last sync time
  Future<void> _updateLastSyncTime() async {
    await _localStorage.saveString(
      'last_sync_time',
      DateTime.now().toIso8601String(),
    );
  }

  /// Force sync specific item
  Future<SyncResult> forceSyncItem(
    String dataType,
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      final endpoint = '/api/$dataType';

      switch (action) {
        case 'create':
          await _apiService.post(endpoint, body: data);
          break;
        case 'update':
          await _apiService.put('$endpoint/${data['id']}', body: data);
          break;
        case 'delete':
          await _apiService.delete('$endpoint/${data['id']}');
          break;
      }

      return SyncResult(
        status: SyncStatus.success,
        message: 'Item synced successfully',
        itemsSynced: 1,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SyncResult(
        status: SyncStatus.error,
        message: 'Failed to sync item: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  void dispose() {
    _autoSyncTimer?.cancel();
    _syncStatusController.close();
  }
}
