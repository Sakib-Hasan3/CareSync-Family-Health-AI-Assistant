import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/user_profile.dart';
import 'user_profile_repository.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = UserProfileRepository();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _insuranceProviderController;
  late TextEditingController _insurancePolicyController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodGroup;
  List<String> _allergies = [];
  List<String> _chronicDiseases = [];
  List<String> _medications = [];

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _addressController = TextEditingController(
      text: widget.profile.address ?? '',
    );
    _emergencyContactController = TextEditingController(
      text: widget.profile.emergencyContact ?? '',
    );
    _emergencyContactNameController = TextEditingController(
      text: widget.profile.emergencyContactName ?? '',
    );
    _insuranceProviderController = TextEditingController(
      text: widget.profile.insuranceProvider ?? '',
    );
    _insurancePolicyController = TextEditingController(
      text: widget.profile.insurancePolicyNumber ?? '',
    );
    _heightController = TextEditingController(
      text: widget.profile.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.profile.weight?.toString() ?? '',
    );

    _selectedDate = widget.profile.dateOfBirth;
    _selectedGender = widget.profile.gender;
    _selectedBloodGroup = widget.profile.bloodGroup;
    _allergies = List.from(widget.profile.allergies ?? []);
    _chronicDiseases = List.from(widget.profile.chronicDiseases ?? []);
    _medications = List.from(widget.profile.medications ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactNameController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updated = widget.profile.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        emergencyContact: _emergencyContactController.text.trim(),
        emergencyContactName: _emergencyContactNameController.text.trim(),
        insuranceProvider: _insuranceProviderController.text.trim(),
        insurancePolicyNumber: _insurancePolicyController.text.trim(),
        height: double.tryParse(_heightController.text.trim()),
        weight: double.tryParse(_weightController.text.trim()),
        allergies: _allergies,
        chronicDiseases: _chronicDiseases,
        medications: _medications,
      );

      await _repo.saveProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addItem(String title, List<String> list) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $title',
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => list.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Personal Information', [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Gender',
                  icon: Icons.wc,
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Blood Group',
                  icon: Icons.bloodtype,
                  value: _selectedBloodGroup,
                  items: _bloodGroups,
                  onChanged: (v) => setState(() => _selectedBloodGroup = v),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Contact & Address', [
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Emergency Contact', [
                _buildTextField(
                  controller: _emergencyContactNameController,
                  label: 'Emergency Contact Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emergencyContactController,
                  label: 'Emergency Contact Phone',
                  icon: Icons.phone_in_talk,
                  keyboardType: TextInputType.phone,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Health Information', [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        icon: Icons.height,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        icon: Icons.monitor_weight,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildListField('Allergies', _allergies),
                const SizedBox(height: 16),
                _buildListField('Chronic Diseases', _chronicDiseases),
                const SizedBox(height: 16),
                _buildListField('Current Medications', _medications),
              ]),
              const SizedBox(height: 24),
              _buildSection('Insurance Information', [
                _buildTextField(
                  controller: _insuranceProviderController,
                  label: 'Insurance Provider',
                  icon: Icons.health_and_safety,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _insurancePolicyController,
                  label: 'Policy Number',
                  icon: Icons.confirmation_number,
                ),
              ]),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF2563EB),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
              : 'Select date',
          style: TextStyle(
            color: _selectedDate != null ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildListField(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            TextButton.icon(
              onPressed: () => _addItem(title, items),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No $title added',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Chip(
                    label: Text(item),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => items.remove(item)),
                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF2563EB)),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
