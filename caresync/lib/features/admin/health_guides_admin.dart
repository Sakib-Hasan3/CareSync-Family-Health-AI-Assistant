import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthGuidesAdminPage extends StatefulWidget {
  const HealthGuidesAdminPage({super.key});

  @override
  State<HealthGuidesAdminPage> createState() => _HealthGuidesAdminPageState();
}

class _HealthGuidesAdminPageState extends State<HealthGuidesAdminPage> {
  final _firestore = FirebaseFirestore.instance;
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Guides & Articles'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Health Guide/Article',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _categoryCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Nutrition, Exercise, Mental Health',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _authorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                          hintText: 'Write the full article content here...',
                        ),
                        maxLines: 10,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tagsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tags (comma separated)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., diet, wellness, prevention',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _addArticle,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Article'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('health_guides')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final articles = snapshot.data!.docs;
                if (articles.isEmpty) {
                  return const Center(child: Text('No articles added yet'));
                }
                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final doc = articles[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        title: Text(
                          data['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${data['category'] ?? ''} • By ${data['author'] ?? 'Unknown'}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['content'] ?? ''),
                                if (data['tags'] != null) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children: (data['tags'] as List)
                                        .map(
                                          (tag) => Chip(
                                            label: Text(tag),
                                            backgroundColor: Colors.blue.shade50,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _deleteArticle(doc.id),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addArticle() async {
    if (_titleCtrl.text.trim().isEmpty) return;

    try {
      await _firestore.collection('health_guides').add({
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'author': _authorCtrl.text.trim(),
        'tags': _tagsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleCtrl.clear();
      _contentCtrl.clear();
      _categoryCtrl.clear();
      _authorCtrl.clear();
      _tagsCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteArticle(String id) async {
    await _firestore.collection('health_guides').doc(id).delete();
  }
}
