import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

/// Profile screen for viewing and managing family members
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> _familyMembers = [
    {
      'name': 'John Doe',
      'relationship': 'Self',
      'age': 35,
      'bloodType': 'O+',
      'avatar': Icons.person,
    },
    {
      'name': 'Jane Doe',
      'relationship': 'Spouse',
      'age': 32,
      'bloodType': 'A+',
      'avatar': Icons.person_outline,
    },
    {
      'name': 'Emily Doe',
      'relationship': 'Daughter',
      'age': 8,
      'bloodType': 'O+',
      'avatar': Icons.child_care,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.familyMembers),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-family-member');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: AppStrings.addFamilyMember,
              icon: Icons.person_add,
              onPressed: () {
                Navigator.of(context).pushNamed('/add-family-member');
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) {
                final member = _familyMembers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor,
                      child: Icon(
                        member['avatar'] as IconData,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      member['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member['relationship']} • ${member['age']} years old',
                        ),
                        Text('Blood Type: ${member['bloodType']}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editMember(index);
                        } else if (value == 'delete') {
                          _deleteMember(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
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
                    onTap: () => _viewMemberDetails(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _viewMemberDetails(int index) {
    final member = _familyMembers[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Relationship: ${member['relationship']}'),
            Text('Age: ${member['age']} years'),
            Text('Blood Type: ${member['bloodType']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editMember(index);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _editMember(int index) {
    // Navigate to edit screen
    Navigator.of(context).pushNamed(
      '/add-family-member',
      arguments: {
        'isEdit': true,
        'member': _familyMembers[index],
        'index': index,
      },
    );
  }

  void _deleteMember(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: Text(
          'Are you sure you want to remove ${_familyMembers[index]['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _familyMembers.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Family member removed')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
