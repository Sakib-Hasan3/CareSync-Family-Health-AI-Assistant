import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Add/Edit medication screen
class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormKey>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prescribedByController = TextEditingController();
  
  String? _selectedFrequency;
  DateTime? _startDate;
  DateTime? _endDate;
  List<TimeOfDay> _reminderTimes = [];
  bool _isLoading = false;
  bool _isEdit = false;

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Weekly',
    'As needed',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['isEdit'] == true) {
      _isEdit = true;
      final medication = args['medication'] as Map<String, dynamic>;
      _nameController.text = medication['name'] as String;
      _dosageController.text = medication['dosage'] as String;
      _prescribedByController.text = medication['prescribedBy'] as String;
      _selectedFrequency = medication['frequency'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Medication' : AppStrings.addMedication),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.medicationName,
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (value) => Validators.required(value, 'Medication name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: AppStrings.dosage,
                prefixIcon: Icon(Icons.medical_services),
                hintText: 'e.g., 10mg, 1 tablet',
              ),
              validator: (value) => Validators.required(value, 'Dosage'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              decoration: const InputDecoration(
                labelText: AppStrings.frequency,
                prefixIcon: Icon(Icons.schedule),
              ),
              items: _frequencies.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value;
                  _updateReminderTimes();
                });
              },
              validator: (value) => value == null ? 'Please select frequency' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _startDate == null
                    ? 'Select Start Date'
                    : 'Start: ${AppUtils.formatDate(_startDate!)}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectStartDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(
                _endDate == null
                    ? 'Select End Date (Optional)'
                    : 'End: ${AppUtils.formatDate(_endDate!)}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectEndDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 16),
            if (_reminderTimes.isNotEmpty) ..[
              const Text(
                'Reminder Times:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._reminderTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.alarm),
                    title: Text(time.format(context)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editReminderTime(index),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: AppStrings.instructions + ' (Optional)',
                prefixIcon: Icon(Icons.description),
                hintText: 'Take with food, etc.',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prescribedByController,
              decoration: const InputDecoration(
                labelText: 'Prescribed By (Optional)',
                prefixIcon: Icon(Icons.person),
                hintText: 'Dr. Smith',
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _isEdit ? 'Update Medication' : 'Add Medication',
              onPressed: _saveMedication,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _updateReminderTimes() {
    _reminderTimes.clear();
    if (_selectedFrequency == null) return;

    switch (_selectedFrequency!) {
      case 'Once daily':
        _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];
        break;
      case 'Twice daily':
        _reminderTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case 'Three times daily':
        _reminderTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case 'Four times daily':
        _reminderTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 16, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case 'Weekly':
        _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];
        break;
      default:
        _reminderTimes = [];
    }
    setState(() {});
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate?.add(const Duration(days: 30)) ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _editReminderTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index],
    );
    if (picked != null) {
      setState(() {
        _reminderTimes[index] = picked;
      });
    }
  }

  void _saveMedication() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startDate == null) {
        AppUtils.showErrorSnackBar(context, 'Please select a start date');
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        // Simulate saving
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          AppUtils.showSuccessSnackBar(
            context, 
            _isEdit ? 'Medication updated successfully!' : 'Medication added successfully!'
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showErrorSnackBar(context, 'Failed to save medication');
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
    _dosageController.dispose();
    _instructionsController.dispose();
    _prescribedByController.dispose();
    super.dispose();
  }
}