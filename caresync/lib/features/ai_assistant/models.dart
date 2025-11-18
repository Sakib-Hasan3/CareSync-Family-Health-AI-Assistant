enum AICategory { symptom, medication, firstAid, education }

extension AICategoryLabel on AICategory {
  String get label {
    switch (this) {
      case AICategory.symptom:
        return 'Symptom';
      case AICategory.medication:
        return 'Medication';
      case AICategory.firstAid:
        return 'First Aid';
      case AICategory.education:
        return 'Education';
    }
  }
}

class AIMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  final DateTime timestamp;
  final AICategory? category;

  AIMessage({
    required this.role,
    required this.text,
    DateTime? timestamp,
    this.category,
  }) : timestamp = timestamp ?? DateTime.now();
}

const String medicalDisclaimer =
    'Educational only — not a diagnosis or a substitute for professional medical advice. If you have a medical emergency, call your local emergency number.';
