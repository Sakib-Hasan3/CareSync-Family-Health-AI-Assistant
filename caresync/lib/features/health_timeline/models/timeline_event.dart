enum TimelineEventType {
  appointment,
  medication,
  medicalRecord,
  alert,
  symptom,
  vitals,
}

/// Lightweight, in-memory timeline event used to render the Health Timeline.
class TimelineEvent {
  final String id;
  final DateTime timestamp;
  final TimelineEventType type;
  final String title;
  final String? subtitle;
  final String? referenceId;
  final Map<String, dynamic>? meta;

  TimelineEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    this.subtitle,
    this.referenceId,
    this.meta,
  });

  TimelineEvent copyWith({
    String? id,
    DateTime? timestamp,
    TimelineEventType? type,
    String? title,
    String? subtitle,
    String? referenceId,
    Map<String, dynamic>? meta,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      referenceId: referenceId ?? this.referenceId,
      meta: meta ?? this.meta,
    );
  }

  @override
  String toString() {
    return 'TimelineEvent($type, $title, ${timestamp.toIso8601String()})';
  }
}
