import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

/// Inlined secure storage helper.
class AIKeyStore {
  static const String _storageKey = 'OPENROUTER_API_KEY';
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

// Keep old name as alias so other files still compile.
typedef GeminiKeyStore = AIKeyStore;

class AIService {
  static const String _envKey = String.fromEnvironment('OPENROUTER_API_KEY');
  static const String _envProxy = String.fromEnvironment('AI_PROXY_URL');

  static const String _openRouterUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _openRouterModel = 'openai/gpt-oss-120b:free';

  final String? apiKey;
  final String? _proxyUrl;

  // Gemini model is kept as an optional fallback only when no OpenRouter key.
  GenerativeModel? _geminiModel;

  AIService({String? apiKey})
      : apiKey = apiKey ?? (_envKey.isEmpty ? null : _envKey),
        _proxyUrl = _envProxy.isEmpty ? null : _envProxy;

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  static Future<bool> hasAnyApiKey() async {
    if (_envKey.isNotEmpty) return true;
    final stored = await AIKeyStore.getKey();
    return stored != null && stored.isNotEmpty;
  }

  Future<String> ask(String question, {AICategory? category}) async {
    // 1. Prefer proxy if configured.
    if (_proxyUrl != null) {
      final uri = Uri.parse('$_proxyUrl/ask');
      final body = jsonEncode({
        'question': question,
        'category': category?.toString().split('.').last,
      });
      try {
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        if (res.statusCode != 200) {
          throw StateError('API_ERROR:${res.statusCode}');
        }
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final text = (data['text'] as String?)?.trim();
        if (text == null || text.isEmpty) throw StateError('EMPTY_RESPONSE');
        return text;
      } catch (e) {
        throw StateError('UNKNOWN_ERROR:$e');
      }
    }

    // 2. Use OpenRouter (primary).
    final openRouterKey = await _resolveKey();
    if (openRouterKey != null) {
      return _callOpenRouter(
        systemPrompt: _systemPrompt(category),
        userMessage: question,
        apiKey: openRouterKey,
      );
    }

    // 3. Fallback to Gemini if an old Gemini key exists.
    await _ensureGeminiModel();
    if (_geminiModel == null) throw StateError('NO_API_K');
    final sys = _systemPrompt(category);
    final content = [Content.system(sys), Content.text(question)];
    try {
      final resp = await _geminiModel!.generateContent(content);
      final text = resp.text?.trim();
      if (text == null || text.isEmpty) throw StateError('EMPTY_RESPONSE');
      return text;
    } on GenerativeAIException catch (e) {
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
    // If proxy is configured, send the image as base64 to the proxy which
    // can handle multimodal requests server-side.
    if (_proxyUrl != null) {
      final uri = Uri.parse('$_proxyUrl/askWithImage');
      final payload = jsonEncode({
        'prompt': prompt,
        'mime_type': mimeType ?? 'image/jpeg',
        'image_b64': base64Encode(imageBytes),
        'category': category?.toString().split('.').last,
      });
      try {
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        );
        if (res.statusCode != 200) {
          throw StateError('API_ERROR:${res.statusCode}');
        }
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final text = (data['text'] as String?)?.trim();
        if (text == null || text.isEmpty) throw StateError('EMPTY_RESPONSE');
        return text;
      } catch (e) {
        throw StateError('UNKNOWN_ERROR:$e');
      }
    }

    await _ensureGeminiModel();
    if (_geminiModel == null) {
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
      final resp = await _geminiModel!.generateContent(parts);
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

  /// Call the OpenRouter chat completions endpoint.
  Future<String> _callOpenRouter({
    required String systemPrompt,
    required String userMessage,
    required String apiKey,
  }) async {
    final uri = Uri.parse(_openRouterUrl);
    final body = jsonEncode({
      'model': _openRouterModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userMessage},
      ],
    });
    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (res.statusCode != 200) {
        throw StateError('API_ERROR:${res.statusCode} ${res.body}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text =
          (data['choices']?[0]?['message']?['content'] as String?)?.trim();
      if (text == null || text.isEmpty) throw StateError('EMPTY_RESPONSE');
      return text;
    } catch (e) {
      throw StateError('UNKNOWN_ERROR:$e');
    }
  }

  /// Resolve the OpenRouter key: constructor arg → dart-define → secure storage.
  Future<String?> _resolveKey() async {
    if (apiKey != null && apiKey!.isNotEmpty) return apiKey;
    if (_envKey.isNotEmpty) return _envKey;
    return AIKeyStore.getKey();
  }

  /// Ensure Gemini model is initialized (fallback only).
  Future<void> _ensureGeminiModel() async {
    if (_geminiModel != null) return;
    if (_proxyUrl != null) return;
    // Only try Gemini if there is no OpenRouter key.
    final orKey = await _resolveKey();
    if (orKey != null && orKey.isNotEmpty) return;
    // Attempt to load a legacy Gemini key stored under the old storage key.
    const legacyStorage = FlutterSecureStorage();
    final geminiKey = await legacyStorage.read(key: 'GEMINI_API_KEY');
    if (geminiKey != null && geminiKey.isNotEmpty) {
      _geminiModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiKey);
    }
  }

  /// Persist an API key into secure storage so it can be used later.
  static Future<void> setApiKey(String key) async {
    await AIKeyStore.saveKey(key);
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
    final key = await AIKeyStore.getKey();
    if (!mounted) return;
    _controller.text = key ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    final val = _controller.text.trim();
    setState(() => _saving = true);
    if (val.isEmpty) {
      await AIKeyStore.deleteKey();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('API key cleared')));
    } else {
      await AIKeyStore.saveKey(val);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key saved securely')),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
  }

  Future<void> _clear() async {
    await AIKeyStore.deleteKey();
    _controller.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API key removed')));
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
              'AI Service API Key',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste your OpenRouter API key (sk-or-v1-...)',
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
                    'You can also provide the key at build/run time using `--dart-define=GEMINI_API_KEY=...`. For production, consider a backend proxy to avoid shipping secret keys in the app.',
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
