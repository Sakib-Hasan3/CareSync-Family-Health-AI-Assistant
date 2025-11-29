import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'payment_account_page.dart';
import '../payments/payment_accounts.dart';
import '../models/doctor.dart';
import '../models/department.dart';
import '../appointment_repository.dart';
import '../appointment_reminder_service.dart';
import '../models/appointment.dart';
import '../appointment_pdf_generator.dart';

class BookingPaymentPage extends StatefulWidget {
  final Doctor doctor;
  final Department department;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;

  const BookingPaymentPage({
    super.key,
    required this.doctor,
    required this.department,
    this.initialDate,
    this.initialTime,
  });

  @override
  State<BookingPaymentPage> createState() => _BookingPaymentPageState();
}

class _BookingPaymentPageState extends State<BookingPaymentPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  final _notesCtrl = TextEditingController();
  String _paymentMethod = 'Cash';
  bool _booking = false;

  final AppointmentRepository _repo = AppointmentRepository();
  final AppointmentReminderService _rem = AppointmentReminderService();

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) _selectedDate = widget.initialDate!;
    if (widget.initialTime != null) _selectedTime = widget.initialTime;
    _repo.init();
    _rem.initialize();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF20B2AA),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF20B2AA),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF20B2AA),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF20B2AA),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _generateTxId() =>
      'TX-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

  Future<void> _confirmBooking() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select appointment time'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _booking = true);

    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final appt = Appointment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Appointment with ${widget.doctor.name}',
      doctorName: widget.doctor.name,
      clinic: widget.doctor.clinic,
      dateTime: dt,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      reminderMinutesBefore: 60,
    );

    await _repo.addOrUpdate(appt);
    await _rem.scheduleReminder(appt);

    // Payment handling (simulate external flow). We generate a transaction id.
    final tx = _generateTxId();
    // After confirming booking, if user chose non-cash, offer the account page with final reference

    // Generate PDF
    final pdfBytes = await AppointmentPdfGenerator.generatePdfBytes(
      appt,
      widget.department.name,
      _paymentMethod,
      tx,
    );

    setState(() => _booking = false);

    if (!mounted) return;

    // Show success dialog and provide quick access to payment page if needed
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildSuccessDialog(appt, tx, pdfBytes),
    );

    // If user picked bKash/Nagad, open the payment account page so they can complete payment,
    // passing the real booking id/reference so it can be copied into the payment app.
    if (_paymentMethod != 'Cash') {
      final method = _paymentMethod;
      final account = PaymentAccounts.accountNumberFor(method);
      final receiver = PaymentAccounts.receiverFor(method);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentAccountPage(
              method: method,
              accountNumber: account,
              receiverName: receiver,
              reference: appt.id,
            ),
          ),
        );
      });
    }

    Navigator.of(context).pop(appt);
  }

  Widget _buildSuccessDialog(Appointment appt, String tx, Uint8List pdfBytes) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF20B2AA).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF20B2AA),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Appointment Confirmed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Doctor', widget.doctor.name),
                  _buildDetailRow(
                    'Date',
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  _buildDetailRow('Time', _selectedTime?.format(context) ?? ''),
                  _buildDetailRow('Booking ID', appt.id),
                  _buildDetailRow('Transaction', tx),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF20B2AA),
                      side: const BorderSide(color: Color(0xFF20B2AA)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await AppointmentPdfGenerator.openPdfBytes(
                        pdfBytes,
                        'appointment_${appt.id}.pdf',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF20B2AA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Download PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Card
              _buildDoctorCard(),
              const SizedBox(height: 24),

              // Appointment Details Section
              _buildSectionHeader('Appointment Details'),
              const SizedBox(height: 16),

              // Date & Time Selection
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeButton(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value:
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimeButton(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: _selectedTime?.format(context) ?? 'Select Time',
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes Section
              _buildSectionHeader('Additional Notes'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _notesCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Any symptoms, concerns, or special requests...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Section
              _buildSectionHeader('Payment Method'),
              const SizedBox(height: 16),
              _buildPaymentSelector(),
              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _booking ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20B2AA),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: const Color(0xFF20B2AA).withOpacity(0.3),
                  ),
                  child: _booking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm & Pay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF20B2AA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctor.specialty,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.doctor.clinic,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF20B2AA)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSelector() {
    const methods = [
      _PaymentMethod(
        name: 'Cash',
        icon: Icons.attach_money_rounded,
        color: Colors.green,
      ),
      _PaymentMethod(
        name: 'bKash',
        icon: Icons.phone_android_rounded,
        color: Color(0xFFE2136E),
      ),
      _PaymentMethod(
        name: 'Nagad',
        icon: Icons.phone_iphone_rounded,
        color: Color(0xFFE30B17),
      ),
    ];

    return Column(
      children: [
        ...methods.map(
          (method) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildPaymentOption(method),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(_PaymentMethod method) {
    final isSelected = _paymentMethod == method.name;

    return GestureDetector(
      onTap: () {
        setState(() => _paymentMethod = method.name);
        if (method.name != 'Cash') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaymentAccountPage.forMethod(method.name),
              ),
            );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: method.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(method.icon, color: method.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: method.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String name;
  final IconData icon;
  final Color color;

  const _PaymentMethod({
    required this.name,
    required this.icon,
    required this.color,
  });
}
