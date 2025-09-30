import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Appointment list screen
class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'doctorName': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'date': DateTime.now().add(const Duration(days: 3)),
      'time': '10:30 AM',
      'location': 'Heart Health Center',
      'type': 'Check-up',
      'status': 'Confirmed',
    },
    {
      'doctorName': 'Dr. Michael Brown',
      'specialty': 'Pediatrician',
      'date': DateTime.now().add(const Duration(days: 7)),
      'time': '2:00 PM',
      'location': 'Children\'s Medical Center',
      'type': 'Vaccination',
      'status': 'Scheduled',
    },
  ];

  final List<Map<String, dynamic>> _pastAppointments = [
    {
      'doctorName': 'Dr. Emily Davis',
      'specialty': 'General Practice',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'time': '9:00 AM',
      'location': 'Family Health Clinic',
      'type': 'Check-up',
      'status': 'Completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appointmentList),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.upcoming)),
            Tab(text: 'Past', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-appointment');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: AppStrings.addAppointment,
              icon: Icons.add,
              onPressed: () {
                Navigator.of(context).pushNamed('/add-appointment');
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingAppointments(),
                _buildPastAppointments(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    if (_upcomingAppointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No upcoming appointments'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _upcomingAppointments[index];
        final date = appointment['date'] as DateTime;
        final isToday = _isToday(date);
        final isTomorrow = _isTomorrow(date);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appointment['doctorName'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editAppointment(index);
                        } else if (value == 'cancel') {
                          _cancelAppointment(index);
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
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  appointment['specialty'] as String,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isToday
                          ? 'Today'
                          : isTomorrow
                          ? 'Tomorrow'
                          : AppUtils.formatDate(date),
                      style: TextStyle(
                        color: isToday
                            ? AppColors.primaryColor
                            : Colors.grey[600],
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      appointment['time'] as String,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        appointment['location'] as String,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          appointment['status'] as String,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        appointment['status'] as String,
                        style: TextStyle(
                          color: _getStatusColor(
                            appointment['status'] as String,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      appointment['type'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastAppointments() {
    if (_pastAppointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No past appointments'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _pastAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _pastAppointments[index];
        final date = appointment['date'] as DateTime;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.check, color: Colors.green),
            ),
            title: Text(appointment['doctorName'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment['specialty'] as String),
                Text('${AppUtils.formatDate(date)} at ${appointment['time']}'),
              ],
            ),
            trailing: Text(
              appointment['type'] as String,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'scheduled':
        return AppColors.primaryColor;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _editAppointment(int index) {
    Navigator.of(context).pushNamed(
      '/add-appointment',
      arguments: {
        'isEdit': true,
        'appointment': _upcomingAppointments[index],
        'index': index,
      },
    );
  }

  void _cancelAppointment(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text(
          'Are you sure you want to cancel the appointment with ${_upcomingAppointments[index]['doctorName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _upcomingAppointments[index]['status'] = 'Cancelled';
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment cancelled')),
              );
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
