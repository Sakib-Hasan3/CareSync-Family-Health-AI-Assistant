import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Add/Edit family member screen
class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _allergiesController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedRelationship;
  String? _selectedBloodType;
  bool _isLoading = false;
  bool _isEdit = false;

  final List<String> _relationships = [
    'Self',
    'Spouse',
    'Child',
    'Parent',
    'Sibling',
    'Grandparent',
    'Grandchild',
    'Other',
  ];

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['isEdit'] == true) {
      _isEdit = true;
      final member = args['member'] as Map<String, dynamic>;
      _nameController.text = member['name'] as String;
      _selectedRelationship = member['relationship'] as String;
      _selectedBloodType = member['bloodType'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Family Member' : AppStrings.addFamilyMember,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.name,
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => Validators.required(value, 'Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRelationship,
              decoration: const InputDecoration(
                labelText: AppStrings.relationship,
                prefixIcon: Icon(Icons.family_restroom),
              ),
              items: _relationships.map((relationship) {
                return DropdownMenuItem(
                  value: relationship,
                  child: Text(relationship),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRelationship = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a relationship' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _selectedDate == null
                    ? 'Select Date of Birth'
                    : AppUtils.formatDate(_selectedDate!),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              decoration: const InputDecoration(
                labelText: AppStrings.bloodType,
                prefixIcon: Icon(Icons.bloodtype),
              ),
              items: _bloodTypes.map((bloodType) {
                return DropdownMenuItem(
                  value: bloodType,
                  child: Text(bloodType),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBloodType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: AppStrings.allergies + ' (Optional)',
                prefixIcon: Icon(Icons.warning),
                hintText: 'Separate multiple allergies with commas',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _isEdit ? 'Update Member' : 'Add Member',
              onPressed: _saveMember,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveMember() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        AppUtils.showErrorSnackBar(context, 'Please select a date of birth');
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Simulate saving
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          AppUtils.showSuccessSnackBar(
            context,
            _isEdit
                ? 'Family member updated successfully!'
                : 'Family member added successfully!',
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showErrorSnackBar(context, 'Failed to save family member');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }
}
