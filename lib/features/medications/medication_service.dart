import 'dart:async';
import 'package:flutter/material.dart';
import 'package:caresync/features/health_timeline/iconsax_stub.dart';
import 'models/medication.dart';
import 'medication_repository.dart';

/// Enhanced Gemini Client with AI-powered health insights
class GeminiClient {
  final String apiKey;

  GeminiClient({required this.apiKey});

  /// Analyzes medication interactions using AI
  Future<List<String>> analyzeInteractions(List<Medication> meds) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (meds.isEmpty) return [];

    // Simulate AI analysis with more intelligent responses
    final interactions = <String>[];

    // Check for common interaction patterns
    final hasBloodThinner = meds.any(
      (m) =>
          m.name.toLowerCase().contains('warfarin') ||
          m.name.toLowerCase().contains('aspirin'),
    );

    final hasNsaid = meds.any(
      (m) =>
          m.name.toLowerCase().contains('ibuprofen') ||
          m.name.toLowerCase().contains('naproxen'),
    );

    if (hasBloodThinner && hasNsaid) {
      interactions.add(
        '⚠️ Blood thinners and NSAIDs may increase bleeding risk',
      );
    }

    final hasStatins = meds.any(
      (m) =>
          m.name.toLowerCase().contains('statin') ||
          m.name.toLowerCase().contains('atorvastatin'),
    );

    final hasAntifungal = meds.any(
      (m) => m.name.toLowerCase().contains('fluconazole'),
    );

    if (hasStatins && hasAntifungal) {
      interactions.add('⚠️ Statins with antifungals may cause muscle damage');
    }

    // Add general health tips
    if (meds.length >= 3) {
      interactions.add(
        '💡 You\'re taking multiple medications - consider a medication review',
      );
    }

    return interactions;
  }

  /// Generates intelligent reminder text
  Future<String> generateReminderText(Medication med) async {
    await Future.delayed(const Duration(milliseconds: 250));

    String timeAdvice = '';
    if (med.time.isNotEmpty) {
      timeAdvice = ' at ${med.time}';
    }

    String foodAdvice = '';
    if (med.name.toLowerCase().contains('metformin')) {
      foodAdvice = ' with food to reduce stomach upset';
    } else if (med.name.toLowerCase().contains('aspirin')) {
      foodAdvice = ' with food to protect your stomach';
    }

    return '💊 Time for ${med.name} (${med.dosage})$timeAdvice$foodAdvice. ${med.frequency}.';
  }

  /// Provides medication-specific health tips
  Future<List<String>> getHealthTips(Medication med) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final tips = <String>[];
    final name = med.name.toLowerCase();

    if (name.contains('blood pressure') || name.contains('lisinopril')) {
      tips.add('Monitor your blood pressure regularly');
      tips.add('Avoid sudden position changes to prevent dizziness');
      tips.add('Limit alcohol consumption');
    }

    if (name.contains('diabetes') || name.contains('metformin')) {
      tips.add('Check blood sugar levels as directed');
      tips.add('Stay hydrated and maintain regular meals');
      tips.add('Watch for signs of low blood sugar');
    }

    if (name.contains('cholesterol') || name.contains('statin')) {
      tips.add('Continue with heart-healthy diet');
      tips.add('Report any muscle pain to your doctor');
      tips.add('Avoid grapefruit and grapefruit juice');
    }

    if (name.contains('pain') || name.contains('ibuprofen')) {
      tips.add('Take with food or milk');
      tips.add('Avoid prolonged use without medical advice');
      tips.add('Watch for stomach discomfort');
    }

    return tips;
  }
}

/// Enhanced Interaction Checker with comprehensive rules
class InteractionChecker {
  static final Map<String, List<InteractionRule>> _rules = {
    'warfarin': [
      InteractionRule(
        conflictingSubstances: [
          'aspirin',
          'ibuprofen',
          'naproxen',
          'fish oil',
          'vitamin e',
        ],
        severity: InteractionSeverity.high,
        message: 'increases bleeding risk significantly',
      ),
      InteractionRule(
        conflictingSubstances: ['antibiotic', 'fluconazole', 'metronidazole'],
        severity: InteractionSeverity.medium,
        message: 'may affect blood thinning levels',
      ),
    ],
    'metformin': [
      InteractionRule(
        conflictingSubstances: ['contrast', 'iodine'],
        severity: InteractionSeverity.high,
        message: 'risk of kidney damage - inform your doctor before scans',
      ),
    ],
    'statin': [
      InteractionRule(
        conflictingSubstances: ['gemfibrozil', 'antibiotic', 'antifungal'],
        severity: InteractionSeverity.high,
        message: 'increased risk of muscle damage',
      ),
      InteractionRule(
        conflictingSubstances: ['grapefruit'],
        severity: InteractionSeverity.medium,
        message: 'may increase side effects - avoid grapefruit',
      ),
    ],
    'blood pressure': [
      InteractionRule(
        conflictingSubstances: ['nsaid', 'ibuprofen', 'naproxen'],
        severity: InteractionSeverity.medium,
        message: 'may reduce blood pressure medication effectiveness',
      ),
    ],
    'diuretic': [
      InteractionRule(
        conflictingSubstances: ['nsaid', 'ibuprofen'],
        severity: InteractionSeverity.medium,
        message: 'may reduce diuretic effect',
      ),
    ],
  };

  List<MedicationAlert> check(List<Medication> meds) {
    final alerts = <MedicationAlert>[];
    final lowerNames = meds.map((m) => m.name.toLowerCase()).toList();

    for (var med in meds) {
      final key = med.name.toLowerCase();

      // Check each rule pattern
      for (var ruleKey in _rules.keys) {
        if (key.contains(ruleKey)) {
          for (var rule in _rules[ruleKey]!) {
            for (var conflict in rule.conflictingSubstances) {
              if (lowerNames.any((n) => n.contains(conflict) && n != key)) {
                alerts.add(
                  MedicationAlert(
                    type: AlertType.interaction,
                    severity: rule.severity,
                    title: 'Medication Interaction',
                    message:
                        '${med.name} may interact with medications containing $conflict - ${rule.message}',
                    medicationId: med.id,
                    timestamp: DateTime.now(),
                  ),
                );
              }
            }
          }
        }
      }
    }

    return alerts;
  }
}

class InteractionRule {
  final List<String> conflictingSubstances;
  final InteractionSeverity severity;
  final String message;

  const InteractionRule({
    required this.conflictingSubstances,
    required this.severity,
    required this.message,
  });
}

enum InteractionSeverity {
  low(Icons.info, Colors.blue, 'Low Risk'),
  medium(Icons.warning_amber_rounded, Colors.orange, 'Medium Risk'),
  high(Icons.dangerous, Colors.red, 'High Risk');

  final IconData icon;
  final Color color;
  final String label;

  const InteractionSeverity(this.icon, this.color, this.label);
}

enum AlertType {
  interaction(Icons.medical_services, Colors.red),
  refill(Icons.inventory, Colors.orange),
  reminder(Icons.access_time, Colors.blue),
  general(Icons.info, Colors.green);

  final IconData icon;
  final Color color;

  const AlertType(this.icon, this.color);
}

class MedicationAlert {
  final AlertType type;
  final InteractionSeverity? severity;
  final String title;
  final String message;
  final String medicationId;
  final DateTime timestamp;
  bool isRead;

  MedicationAlert({
    required this.type,
    this.severity,
    required this.title,
    required this.message,
    required this.medicationId,
    required this.timestamp,
    this.isRead = false,
  });
}

/// Enhanced Medication Alerts Service with comprehensive monitoring
class MedicationAlertsService {
  final MedicationRepository repository;
  final GeminiClient? geminiClient;
  final InteractionChecker _checker = InteractionChecker();
  final StreamController<List<MedicationAlert>> _alertsController =
      StreamController<List<MedicationAlert>>.broadcast();

  MedicationAlertsService({required this.repository, this.geminiClient});

  Stream<List<MedicationAlert>> get alertsStream => _alertsController.stream;

  Future<List<MedicationAlert>> gatherAlerts({bool online = false}) async {
    final meds = repository.getAll();
    final alerts = <MedicationAlert>[];

    // Refill alerts
    for (var m in meds) {
      if (m.remaining <= m.refillThreshold && m.remaining > 0) {
        alerts.add(
          MedicationAlert(
            type: AlertType.refill,
            title: 'Refill Needed',
            message:
                '${m.name} is running low. Only ${m.remaining} doses left.',
            medicationId: m.id,
            timestamp: DateTime.now(),
          ),
        );
      }

      if (m.remaining == 0) {
        alerts.add(
          MedicationAlert(
            type: AlertType.refill,
            severity: InteractionSeverity.high,
            title: 'Out of Stock',
            message: '${m.name} is out of stock. Please refill immediately.',
            medicationId: m.id,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // Offline interaction checks
    final interactionAlerts = _checker.check(meds);
    alerts.addAll(interactionAlerts);

    // Reminder alerts for medications due today
    final todayMeds = _getTodaysMedications(meds);
    for (var med in todayMeds) {
      alerts.add(
        MedicationAlert(
          type: AlertType.reminder,
          title: 'Medication Due',
          message: 'Time to take ${med.name} (${med.dosage})',
          medicationId: med.id,
          timestamp: DateTime.now(),
        ),
      );
    }

    // If online and Gemini client provided, get AI insights
    if (online && geminiClient != null) {
      try {
        final aiInteractions = await geminiClient!.analyzeInteractions(meds);
        for (var interaction in aiInteractions) {
          alerts.add(
            MedicationAlert(
              type: AlertType.interaction,
              severity: InteractionSeverity.medium,
              title: 'AI Health Insight',
              message: interaction,
              medicationId: '',
              timestamp: DateTime.now(),
            ),
          );
        }

        // Get health tips for each medication
        for (var med in meds) {
          final tips = await geminiClient!.getHealthTips(med);
          for (var tip in tips.take(1)) {
            // Show one most relevant tip per med
            alerts.add(
              MedicationAlert(
                type: AlertType.general,
                title: 'Health Tip for ${med.name}',
                message: tip,
                medicationId: med.id,
                timestamp: DateTime.now(),
              ),
            );
          }
        }
      } catch (_) {
        // Fail gracefully - offline mode will still work
      }
    }

    // Sort alerts by severity and timestamp
    alerts.sort((a, b) {
      final severityA = a.severity ?? InteractionSeverity.low;
      final severityB = b.severity ?? InteractionSeverity.low;

      if (severityA.index != severityB.index) {
        return severityB.index.compareTo(
          severityA.index,
        ); // High severity first
      }
      return b.timestamp.compareTo(a.timestamp); // Newest first
    });

    _alertsController.add(alerts);
    return alerts;
  }

  List<Medication> _getTodaysMedications(List<Medication> meds) {
    // Simple logic - in real app, this would check against actual schedule
    return meds
        .where((med) => med.remaining > 0)
        .take(2)
        .toList(); // Show first 2 for demo
  }

  void markAlertAsRead(MedicationAlert alert) {
    alert.isRead = true;
    // Notify listeners about the update
    _alertsController.add([]); // Trigger rebuild
  }

  void markAllAlertsAsRead(List<MedicationAlert> alerts) {
    for (var alert in alerts) {
      alert.isRead = true;
    }
    _alertsController.add([]); // Trigger rebuild
  }

  void dispose() {
    _alertsController.close();
  }
}

// UI Components for displaying alerts
class MedicationAlertsPanel extends StatelessWidget {
  final List<MedicationAlert> alerts;
  final VoidCallback onViewAll;
  final Function(MedicationAlert) onAlertTap;

  const MedicationAlertsPanel({
    super.key,
    required this.alerts,
    required this.onViewAll,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    final unreadAlerts = alerts.where((alert) => !alert.isRead).toList();
    final highPriorityAlerts = unreadAlerts
        .where((alert) => alert.severity == InteractionSeverity.high)
        .toList();

    if (unreadAlerts.isEmpty) {
      return _buildNoAlertsCard();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(unreadAlerts.length, onViewAll),
          const SizedBox(height: 12),
          ...highPriorityAlerts
              .take(2)
              .map(
                (alert) =>
                    _AlertCard(alert: alert, onTap: () => onAlertTap(alert)),
              )
              .toList(),
          if (unreadAlerts.length > 2) _buildViewMoreButton(onViewAll),
        ],
      ),
    );
  }

  Widget _buildHeader(int alertCount, VoidCallback onViewAll) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Iconsax.warning_2, color: Colors.red, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'Medication Alerts ($alertCount)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'View All',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoAlertsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.tick_circle,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Clear!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No medication alerts at this time',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton(VoidCallback onViewAll) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: onViewAll,
        icon: const Icon(Iconsax.eye, size: 16),
        label: const Text('View All Alerts'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final MedicationAlert alert;
  final VoidCallback onTap;

  const _AlertCard({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(alert.severity),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alert Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getIconColor(alert.severity).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAlertIcon(alert.type, alert.severity),
                    color: _getIconColor(alert.severity),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Alert Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(alert.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Severity Badge
                if (alert.severity != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: alert.severity!.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alert.severity!.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: alert.severity!.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getIconColor(InteractionSeverity? severity) {
    return severity?.color ?? AlertType.general.color;
  }

  Color _getBorderColor(InteractionSeverity? severity) {
    return severity?.color.withOpacity(0.3) ?? Colors.grey.shade200;
  }

  IconData _getAlertIcon(AlertType type, InteractionSeverity? severity) {
    if (severity != null) return severity.icon;
    return type.icon;
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
