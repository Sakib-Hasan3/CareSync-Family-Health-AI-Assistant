import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'ai_service.dart';
import 'models.dart';
import 'offline_knowledge_base.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _controller = TextEditingController();
  final _messages = <AIMessage>[];
  AICategory _category = AICategory.symptom;
  late final AIService _ai;
  final _kb = OfflineKnowledgeBase();
  bool _loading = false;
  String? _error;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _ai = AIService();
    _kb.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(AIMessage(role: 'user', text: text, category: _category));
      _loading = true;
      _error = null;
      _controller.clear();
    });

    String reply;
    try {
      final results = await Connectivity().checkConnectivity();
      final hasNet = results.any((c) => c != ConnectivityResult.none);
      final hasKey = await AIService.hasAnyApiKey();
      final online = hasNet && hasKey;
      if (online) {
        reply = await _ai.ask(text, category: _category);
      } else {
        if (!_kb.isLoaded) {
          await _kb.load();
        }
        reply = _kb.search(text);
        reply = _appendDisclaimer(reply);
      }
    } catch (e) {
      if (!_kb.isLoaded) {
        await _kb.load();
      }
      reply = _appendDisclaimer(_kb.search(text));
      _error = e.toString();
    }

    if (!mounted) return;
    setState(() {
      _messages.add(
        AIMessage(role: 'assistant', text: reply, category: _category),
      );
      _loading = false;
    });
  }

  Future<void> _sendImage() async {
    setState(() {
      _error = null;
    });
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
      );
      if (img == null) return;
      final bytes = await img.readAsBytes();
      setState(() {
        _messages.add(
          AIMessage(
            role: 'user',
            text: '[Image selected: ${img.name}]',
            category: _category,
          ),
        );
        _loading = true;
      });

      String reply;
      final results = await Connectivity().checkConnectivity();
      final hasNet = results.any((c) => c != ConnectivityResult.none);
      final hasKey = await AIService.hasAnyApiKey();
      final online = hasNet && hasKey;
      if (online) {
        reply = await _ai.askWithImage(
          bytes,
          mimeType: img.mimeType ?? 'image/jpeg',
          category: _category,
        );
      } else {
        reply = _appendDisclaimer(
          'Image analysis requires internet access and an API key.',
        );
      }

      if (!mounted) return;
      setState(() {
        _messages.add(
          AIMessage(role: 'assistant', text: reply, category: _category),
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _appendDisclaimer(String body) {
    return body.trim().endsWith(medicalDisclaimer)
        ? body
        : '${body.trim()}\n\n$medicalDisclaimer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDisclaimer(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'AI settings',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AISettingsPage())),
          ),
        ],
      ),
      // Use a column for content and place the composer into the scaffold's
      // bottomNavigationBar to avoid layout overflow when the keyboard or
      // safe-area insets appear.
      body: Column(
        children: [
          _buildCategoryChips(),
          _buildDisclaimerBanner(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.orange.shade800),
              ),
            ),
          Expanded(child: _buildMessages()),
        ],
      ),
      bottomNavigationBar: _buildComposer(),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: AICategory.values.map((c) {
          final selected = _category == c;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(c.label),
              selected: selected,
              onSelected: (_) => setState(() => _category = c),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_information, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              medicalDisclaimer,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Medical Disclaimer'),
        content: const Text(medicalDisclaimer),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_loading && index == _messages.length) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final msg = _messages[index];
        final isUser = msg.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF2563EB) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.04)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.category != null && !isUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      msg.category!.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isUser ? Colors.white70 : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  msg.text,
                  style: TextStyle(
                    color: isUser ? Colors.white : const Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Pick Image',
              onPressed: _loading ? null : _sendImage,
              icon: const Icon(Icons.image_outlined),
            ),
            IconButton(
              tooltip: 'Voice (coming soon)',
              onPressed: null,
              icon: const Icon(Icons.mic_none),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Ask about symptoms, meds, or first aid...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _loading ? null : _send,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
