import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Document list screen
class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final List<Map<String, dynamic>> _documents = [
    {
      'name': 'Blood Test Results',
      'type': 'Lab Report',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'size': '2.1 MB',
      'icon': Icons.description,
      'color': Colors.red,
    },
    {
      'name': 'Prescription - Lisinopril',
      'type': 'Prescription',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'size': '1.5 MB',
      'icon': Icons.medical_services,
      'color': Colors.blue,
    },
    {
      'name': 'Insurance Card',
      'type': 'Insurance',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'size': '850 KB',
      'icon': Icons.credit_card,
      'color': Colors.green,
    },
    {
      'name': 'X-Ray Chest',
      'type': 'X-Ray',
      'date': DateTime.now().subtract(const Duration(days: 45)),
      'size': '5.2 MB',
      'icon': Icons.medical_information,
      'color': Colors.orange,
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Prescription',
    'Lab Report',
    'Insurance',
    'X-Ray',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = _selectedFilter == 'All'
        ? _documents
        : _documents.where((doc) => doc['type'] == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.documentList),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    if (_selectedFilter == option)
                      const Icon(Icons.check, size: 20),
                    if (_selectedFilter == option) const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/upload-document');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: AppStrings.uploadDocument,
              icon: Icons.upload_file,
              onPressed: () {
                Navigator.of(context).pushNamed('/upload-document');
              },
            ),
          ),
          if (_selectedFilter != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text('Filter: $_selectedFilter'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredDocuments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'All'
                              ? 'No documents uploaded yet'
                              : 'No $_selectedFilter documents',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredDocuments.length,
                    itemBuilder: (context, index) {
                      final document = filteredDocuments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: (document['color'] as Color)
                                .withOpacity(0.1),
                            child: Icon(
                              document['icon'] as IconData,
                              color: document['color'] as Color,
                            ),
                          ),
                          title: Text(
                            document['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(document['type'] as String),
                              Text(
                                '${AppUtils.formatDate(document['date'] as DateTime)} • ${document['size']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'view') {
                                _viewDocument(index);
                              } else if (value == 'share') {
                                _shareDocument(index);
                              } else if (value == 'delete') {
                                _deleteDocument(index);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('View'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    Icon(Icons.share),
                                    SizedBox(width: 8),
                                    Text('Share'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _viewDocument(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _viewDocument(int index) {
    final document = _documents[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${document['type']}'),
            Text('Date: ${AppUtils.formatDate(document['date'] as DateTime)}'),
            Text('Size: ${document['size']}'),
            const SizedBox(height: 16),
            const Text('Document preview would be shown here'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Open full document viewer
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _shareDocument(int index) {
    final document = _documents[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${document['name']}...'),
        action: SnackBarAction(label: 'Cancel', onPressed: () {}),
      ),
    );
  }

  void _deleteDocument(int index) {
    final document = _documents[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _documents.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Document deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
