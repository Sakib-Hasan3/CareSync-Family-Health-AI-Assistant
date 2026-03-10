import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class OfflineKnowledgeBase {
  Map<String, dynamic>? _firstAid;
  Map<String, dynamic>? _symptoms;
  Map<String, dynamic>? _medSafety;

  Future<void> load() async {
    final results = await Future.wait([
      rootBundle.loadString('assets/guides/first_aid.json'),
      rootBundle.loadString('assets/guides/symptoms.json'),
      rootBundle.loadString('assets/guides/medication_safety.json'),
    ]);
    _firstAid = jsonDecode(results[0]) as Map<String, dynamic>;
    _symptoms = jsonDecode(results[1]) as Map<String, dynamic>;
    _medSafety = jsonDecode(results[2]) as Map<String, dynamic>;
  }

  bool get isLoaded =>
      _firstAid != null && _symptoms != null && _medSafety != null;

  String search(String query) {
    final q = query.toLowerCase();
    final buffer = StringBuffer();

    void writeSection(
      Map<String, dynamic>? doc,
      String heading,
      List<String> contentExtractor(Map<String, dynamic> item),
    ) {
      if (doc == null) return;
      final items = (doc['items'] as List).cast<Map<String, dynamic>>();
      final matches = items.where((item) {
        final topic = (item['topic'] ?? '').toString().toLowerCase();
        final body = jsonEncode(item).toLowerCase();
        return topic.contains(q) || body.contains(q);
      }).toList();
      if (matches.isEmpty) return;
      buffer.writeln('## $heading');
      for (final m in matches) {
        final topic = m['topic'] ?? 'Topic';
        buffer.writeln('\n• $topic');
        for (final line in contentExtractor(m)) {
          buffer.writeln('  - $line');
        }
      }
    }

    writeSection(_symptoms, 'Symptoms', (m) {
      final out = <String>[];
      if (m['info'] != null) out.add(m['info']);
      if (m['red_flags'] != null) {
        out.add('Red flags:');
        for (final rf in (m['red_flags'] as List)) {
          out.add('• $rf');
        }
      }
      return out;
    });

    writeSection(_firstAid, 'First Aid', (m) {
      final steps = (m['steps'] as List?)?.cast<String>() ?? const [];
      final out = <String>[];
      for (final s in steps) out.add(s);
      if (m['disclaimer'] != null) out.add('Note: ${m['disclaimer']}');
      return out;
    });

    writeSection(_medSafety, 'Medication Safety', (m) {
      final bullets = (m['bullets'] as List?)?.cast<String>() ?? const [];
      final out = <String>[];
      for (final s in bullets) out.add(s);
      return out;
    });

    if (buffer.isEmpty) {
      return 'No offline tips found for your query. Try rephrasing or check your internet connection for AI-powered answers.';
    }
    return buffer.toString();
  }
}
