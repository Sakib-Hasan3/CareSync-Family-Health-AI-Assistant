import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';

/// Dashboard screen - main app homepage
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _selectedFamilyMember = 'John Doe';

  final List<Map<String, dynamic>> _familyMembers = [
    {'name': 'John Doe', 'relation': 'Self', 'avatar': '👨'},
    {'name': 'Jane Doe', 'relation': 'Spouse', 'avatar': '👩'},
    {'name': 'Emma Doe', 'relation': 'Daughter', 'avatar': '👧'},
    {'name': 'Michael Doe', 'relation': 'Son', 'avatar': '👦'},
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Add Medication',
      'icon': Icons.medication,
      'color': Colors.blue,
      'route': '/add-medication',
    },
    {
      'title': 'Book Appointment',
      'icon': Icons.calendar_today,
      'color': Colors.green,
      'route': '/add-appointment',
    },
    {
      'title': 'Upload Document',
      'icon': Icons.upload_file,
      'color': Colors.orange,
      'route': '/upload-document',
    },
    {
      'title': 'Record Vitals',
      'icon': Icons.favorite,
      'color': Colors.red,
      'route': '/vitals-input',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomePage(),
            _buildProfilesPage(),
            _buildMedicationsPage(),
            _buildAppointmentsPage(),
            _buildMorePage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildFamilyMemberSelector(),
              const SizedBox(height: 24),
              _buildHealthOverview(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildUpcomingSection(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
              const SizedBox(height: 24),
              _buildHealthInsights(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.blue.shade600,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getGreeting()}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Text(
              'CareSync Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.emergency, color: Colors.red),
          onPressed: () => Navigator.of(context).pushNamed('/sos'),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: _showNotifications,
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => Navigator.of(context).pushNamed('/settings'),
        ),
      ],
    );
  }

  Widget _buildFamilyMemberSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Family Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _familyMembers.length,
                itemBuilder: (context, index) {
                  final member = _familyMembers[index];
                  final isSelected = member['name'] == _selectedFamilyMember;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFamilyMember = member['name'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            member['avatar'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member['name'].split(' ')[0],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            member['relation'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/vitals-trend'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    'Blood Pressure',
                    '120/80',
                    'mmHg',
                    Icons.favorite,
                    Colors.red,
                    'Normal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthMetric(
                    'Heart Rate',
                    '72',
                    'bpm',
                    Icons.monitor_heart,
                    Colors.pink,
                    'Normal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    'Weight',
                    '70.5',
                    'kg',
                    Icons.monitor_weight,
                    Colors.blue,
                    'Healthy',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthMetric(
                    'Blood Sugar',
                    '95',
                    'mg/dL',
                    Icons.water_drop,
                    Colors.purple,
                    'Normal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: color.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _quickActions.length,
              itemBuilder: (context, index) {
                final action = _quickActions[index];
                return InkWell(
                  onTap: () => Navigator.of(context).pushNamed(action['route']),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (action['color'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(action['icon'], color: action['color'], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          action['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/appointment-list'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildUpcomingItem(
              'Dr. Sarah Johnson',
              'Cardiology Checkup',
              'Today 2:30 PM',
              Icons.local_hospital,
              Colors.red,
            ),
            const SizedBox(height: 8),
            _buildUpcomingItem(
              'Lisinopril 10mg',
              'Take medication',
              'Today 8:00 PM',
              Icons.medication,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildUpcomingItem(
              'Blood Test',
              'Lab Appointment',
              'Tomorrow 9:00 AM',
              Icons.science,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              'Blood pressure recorded',
              '2 hours ago',
              Icons.favorite,
              Colors.red,
            ),
            _buildActivityItem(
              'Medication taken: Metformin',
              '5 hours ago',
              Icons.medication,
              Colors.blue,
            ),
            _buildActivityItem(
              'Document uploaded: Lab Results',
              '1 day ago',
              Icons.upload_file,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsights() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Health Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Great job maintaining healthy vitals! 🎉',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your blood pressure has been stable for the past week. Keep up the good work with your current medication routine.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilesPage() {
    return const Center(child: Text('Profiles Page - Navigate to /profile'));
  }

  Widget _buildMedicationsPage() {
    return const Center(
      child: Text('Medications Page - Navigate to /medication-list'),
    );
  }

  Widget _buildAppointmentsPage() {
    return const Center(
      child: Text('Appointments Page - Navigate to /appointment-list'),
    );
  }

  Widget _buildMorePage() {
    return const Center(child: Text('More Page - Settings and other options'));
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Navigate to specific pages when tapped
        switch (index) {
          case 1:
            Navigator.of(context).pushNamed('/profile');
            break;
          case 2:
            Navigator.of(context).pushNamed('/medication-list');
            break;
          case 3:
            Navigator.of(context).pushNamed('/appointment-list');
            break;
          case 4:
            Navigator.of(context).pushNamed('/settings');
            break;
        }
      },
      selectedItemColor: Colors.blue.shade600,
      unselectedItemColor: Colors.grey.shade600,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Profiles'),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.medication, color: Colors.blue),
              title: Text('Medication Reminder'),
              subtitle: Text('Take Lisinopril 10mg'),
              trailing: Text('30 min'),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.green),
              title: Text('Appointment Tomorrow'),
              subtitle: Text('Dr. Sarah Johnson'),
              trailing: Text('1 day'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
