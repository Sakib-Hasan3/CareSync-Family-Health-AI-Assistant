import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Add/Edit appointment screen
class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedType;
  bool _setReminder = true;
  bool _isLoading = false;
  bool _isEdit = false;

  final List<String> _appointmentTypes = [
    'Check-up',
    'Consultation',
    'Follow-up',
    'Emergency',
    'Vaccination',
    'Surgery',
    'Therapy',
    'Other',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['isEdit'] == true) {
      _isEdit = true;
      final appointment = args['appointment'] as Map<String, dynamic>;
      _doctorNameController.text = appointment['doctorName'] as String;
      _specialtyController.text = appointment['specialty'] as String;
      _locationController.text = appointment['location'] as String;
      _selectedType = appointment['type'] as String;
      _selectedDate = appointment['date'] as DateTime;
      // Parse time from string
      final timeString = appointment['time'] as String;
      _selectedTime = _parseTimeString(timeString);
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    // Simple parser for "10:30 AM" format
    final parts = timeString.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts.length > 1 && parts[1].toUpperCase() == 'PM';

    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Appointment' : AppStrings.addAppointment),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _doctorNameController,
              decoration: const InputDecoration(
                labelText: AppStrings.doctorName,
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => Validators.required(value, 'Doctor name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialtyController,
              decoration: const InputDecoration(
                labelText: 'Specialty (Optional)',
                prefixIcon: Icon(Icons.medical_services),
                hintText: 'e.g., Cardiologist, Pediatrician',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Appointment Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: _appointmentTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select appointment type' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _selectedDate == null
                    ? 'Select Appointment Date'
                    : AppUtils.formatDate(_selectedDate!),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                _selectedTime == null
                    ? 'Select Appointment Time'
                    : _selectedTime!.format(context),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: AppStrings.location,
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Hospital, clinic, or address',
              ),
              validator: (value) => Validators.required(value, 'Location'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Visit (Optional)',
                prefixIcon: Icon(Icons.description),
                hintText: 'Check-up, follow-up, symptoms, etc.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: AppStrings.notes + ' (Optional)',
                prefixIcon: Icon(Icons.note),
                hintText: 'Additional notes or reminders',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set Reminder'),
              subtitle: const Text('Remind me 1 day and 1 hour before'),
              value: _setReminder,
              onChanged: (value) {
                setState(() {
                  _setReminder = value;
                });
              },
              secondary: const Icon(Icons.notifications),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _isEdit ? 'Update Appointment' : 'Schedule Appointment',
              onPressed: _saveAppointment,
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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveAppointment() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        AppUtils.showErrorSnackBar(
          context,
          'Please select an appointment date',
        );
        return;
      }
      if (_selectedTime == null) {
        AppUtils.showErrorSnackBar(
          context,
          'Please select an appointment time',
        );
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
                ? 'Appointment updated successfully!'
                : 'Appointment scheduled successfully!',
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showErrorSnackBar(context, 'Failed to save appointment');
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
    _doctorNameController.dispose();
    _specialtyController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
