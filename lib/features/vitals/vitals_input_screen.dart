import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Vitals input screen
class VitalsInputScreen extends StatefulWidget {
  const VitalsInputScreen({super.key});

  @override
  State<VitalsInputScreen> createState() => _VitalsInputScreenState();
}

class _VitalsInputScreenState extends State<VitalsInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _oxygenController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vitalsInput),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/vitals-history');
            },
            child: const Text('History'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recording Date & Time',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(AppUtils.formatDateTime(_selectedDateTime)),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectDateTime,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildVitalSection('Blood Pressure', Icons.favorite, Colors.red, [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _systolicController,
                      decoration: const InputDecoration(
                        labelText: 'Systolic',
                        hintText: '120',
                        suffixText: 'mmHg',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _diastolicController,
                      decoration: const InputDecoration(
                        labelText: 'Diastolic',
                        hintText: '80',
                        suffixText: 'mmHg',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildVitalSection('Heart Rate', Icons.monitor_heart, Colors.pink, [
              TextFormField(
                controller: _heartRateController,
                decoration: const InputDecoration(
                  labelText: AppStrings.heartRate,
                  hintText: '72',
                  suffixText: 'bpm',
                ),
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: 16),
            _buildVitalSection('Temperature', Icons.thermostat, Colors.orange, [
              TextFormField(
                controller: _temperatureController,
                decoration: const InputDecoration(
                  labelText: AppStrings.temperature,
                  hintText: '36.5',
                  suffixText: '°C',
                ),
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: 16),
            _buildVitalSection(
              'Body Measurements',
              Icons.straighten,
              Colors.blue,
              [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.weight,
                          hintText: '70',
                          suffixText: 'kg',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.height,
                          hintText: '175',
                          suffixText: 'cm',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVitalSection('Blood Sugar', Icons.water_drop, Colors.purple, [
              TextFormField(
                controller: _bloodSugarController,
                decoration: const InputDecoration(
                  labelText: AppStrings.bloodSugar,
                  hintText: '95',
                  suffixText: 'mg/dL',
                ),
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: 16),
            _buildVitalSection('Oxygen Saturation', Icons.air, Colors.cyan, [
              TextFormField(
                controller: _oxygenController,
                decoration: const InputDecoration(
                  labelText: 'Oxygen Saturation',
                  hintText: '98',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText:
                            'Add any additional notes about your health status...',
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Vitals',
              onPressed: _saveVitals,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveVitals() async {
    // Check if at least one vital is entered
    if (_systolicController.text.isEmpty &&
        _diastolicController.text.isEmpty &&
        _heartRateController.text.isEmpty &&
        _temperatureController.text.isEmpty &&
        _weightController.text.isEmpty &&
        _heightController.text.isEmpty &&
        _bloodSugarController.text.isEmpty &&
        _oxygenController.text.isEmpty) {
      AppUtils.showErrorSnackBar(
        context,
        'Please enter at least one vital measurement',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate saving
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        AppUtils.showSuccessSnackBar(context, 'Vitals saved successfully!');

        // Clear the form
        _systolicController.clear();
        _diastolicController.clear();
        _heartRateController.clear();
        _temperatureController.clear();
        _weightController.clear();
        _heightController.clear();
        _bloodSugarController.clear();
        _oxygenController.clear();
        _notesController.clear();

        setState(() {
          _selectedDateTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackBar(context, 'Failed to save vitals');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bloodSugarController.dispose();
    _oxygenController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
