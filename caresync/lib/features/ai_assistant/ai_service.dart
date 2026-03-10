import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models.dart';

/// Inlined secure storage helper (previously `gemini_key_store.dart`).
class GeminiKeyStore {
  static const String _storageKey = 'GEMINI_API_KEY';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveKey(String key) async {
    await _storage.write(key: _storageKey, value: key);
  }

  static Future<String?> getKey() async {
    return await _storage.read(key: _storageKey);
  }

  static Future<void> deleteKey() async {
    await _storage.delete(key: _storageKey);
  }

  static Future<bool> hasKey() async {
    final v = await getKey();
    return v != null && v.isNotEmpty;
  }
}

class AIService {
  static const String _envKey = String.fromEnvironment('GEMINI_API_KEY');
  final String? apiKey;
  GenerativeModel? _model;

  AIService({String? apiKey})
    : apiKey = apiKey ?? (_envKey.isEmpty ? null : _envKey);

  /// Synchronous indicator whether an API key was passed in constructor
  /// or provided at build time via `--dart-define`.
  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  /// Returns true if any API key is available (env, constructor, or secure store).
  static Future<bool> hasAnyApiKey() async {
    if (_envKey.isNotEmpty) return true;
    final stored = await GeminiKeyStore.getKey();
    return stored != null && stored.isNotEmpty;
  }

  Future<String> ask(String question, {AICategory? category}) async {
    await _ensureModel();
    // If no API key, signal caller to fallback
    if (_model == null) {
      throw StateError('NO_API_K');
    }

    final sys = _systemPrompt(category);
    final content = [Content.system(sys), Content.text(question)];

    try {
      final resp = await _model!.generateContent(content);
      final text = resp.text?.trim();
      if (text == null || text.isEmpty) {
        throw StateError('EMPTY_RESPONSE');
      }
      return text;
    } on GenerativeAIException catch (e) {
      // Bubble a structured error so UI can fallback offline
      throw StateError('API_ERROR:${e.message}');
    } catch (e) {
      throw StateError('UNKNOWN_ERROR:$e');
    }
  }

  /// Ask with an image input (multimodal). Optionally include a text prompt.
  /// mimeType should be a valid image mime, e.g. 'image/jpeg' or 'image/png'.
  Future<String> askWithImage(
    Uint8List imageBytes, {
    String? mimeType,
    String? prompt,
    AICategory? category,
  }) async {
    await _ensureModel();
    if (_model == null) {
      throw StateError('NO_API_K');
    }

    final sys = _systemPrompt(category);
    final parts = <Content>[Content.system(sys)];
    if (prompt != null && prompt.trim().isNotEmpty) {
      parts.add(Content.text(prompt.trim()));
    } else {
      parts.add(
        Content.text(
          'Analyze the health-related aspects in this photo and provide safe, general guidance.',
        ),
      );
    }
    final type = (mimeType == null || mimeType.isEmpty)
        ? 'image/jpeg'
        : mimeType;
    parts.add(Content.data(type, imageBytes));

    try {
      final resp = await _model!.generateContent(parts);
      final text = resp.text?.trim();
      if (text == null || text.isEmpty) {
        throw StateError('EMPTY_RESPONSE');
      }
      return text;
    } on GenerativeAIException catch (e) {
      throw StateError('API_ERROR:${e.message}');
    } catch (e) {
      throw StateError('UNKNOWN_ERROR:$e');
    }
  }

  /// Ensure `_model` is initialized. Preference order: constructor/apiKey ->
  /// build-time env (`--dart-define`) -> secure storage (set in app settings).
  Future<void> _ensureModel() async {
    if (_model != null) return;
    String? keyToUse = apiKey;
    if (keyToUse == null || keyToUse.isEmpty) {
      if (_envKey.isNotEmpty) keyToUse = _envKey;
    }
    if (keyToUse == null || keyToUse.isEmpty) {
      keyToUse = await GeminiKeyStore.getKey();
    }
    if (keyToUse != null && keyToUse.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: keyToUse);
    }
  }

  /// Persist an API key into secure storage so it can be used later.
  static Future<void> setApiKey(String key) async {
    await GeminiKeyStore.saveKey(key);
  }

  String _systemPrompt(AICategory? category) {
    final base =
        'You are a helpful AI health assistant. Always include the following disclaimer at the end of your response: "$medicalDisclaimer". Use clear, plain language with short paragraphs and bullet points when appropriate. Do not fabricate guidelines; avoid definitive diagnoses.';
    switch (category) {
      case AICategory.symptom:
        return '$base Provide general guidance for symptom assessment, typical causes, self-care measures, and red flags that require urgent care.';
      case AICategory.medication:
        return '$base Provide general medication information, common side effects, interactions, and safety tips. Do not provide personalized dosing.';
      case AICategory.firstAid:
        return '$base Provide step-by-step first aid instructions following widely accepted standards (e.g., CPR basics). Keep it concise and safety-first.';
      case AICategory.education:
        return '$base Provide basic health education and preventive advice with references to reputable sources when possible.';
      default:
        return base;
    }
  }
}

/// Inlined settings page (previously `ai_settings_page.dart`).
class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await GeminiKeyStore.getKey();
    if (!mounted) return;
    _controller.text = key ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    final val = _controller.text.trim();
    setState(() => _saving = true);
    if (val.isEmpty) {
      await GeminiKeyStore.deleteKey();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gemini API key cleared')));
    } else {
      await GeminiKeyStore.saveKey(val);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemini API key saved securely')),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
  }

  Future<void> _clear() async {
    await GeminiKeyStore.deleteKey();
    _controller.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gemini API key removed')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemini API Key',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste your Gemini API key here',
              ),
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _clear, child: const Text('Clear')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can also provide the key at build/run time using `--dart-define=GEMINI_API_KEY=...`.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
