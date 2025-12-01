import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildAdminCard(
            context,
            icon: Icons.local_hospital,
            title: 'Medical Info',
            subtitle: 'Symptoms, Conditions',
            color: Colors.red,
            route: '/admin/medical-info',
          ),
          _buildAdminCard(
            context,
            icon: Icons.medication,
            title: 'Medications',
            subtitle: 'Drug Database',
            color: Colors.green,
            route: '/admin/medications',
          ),
          _buildAdminCard(
            context,
            icon: Icons.person,
            title: 'Doctors',
            subtitle: 'Directory Management',
            color: Colors.blue,
            route: '/directory/admin',
          ),
          _buildAdminCard(
            context,
            icon: Icons.article,
            title: 'Health Guides',
            subtitle: 'Articles & Tips',
            color: Colors.orange,
            route: '/admin/health-guides',
          ),
          _buildAdminCard(
            context,
            icon: Icons.quiz,
            title: 'First Aid',
            subtitle: 'Emergency Procedures',
            color: Colors.purple,
            route: '/admin/first-aid',
          ),
          _buildAdminCard(
            context,
            icon: Icons.warning,
            title: 'Safety Info',
            subtitle: 'Medication Safety',
            color: Colors.amber,
            route: '/admin/safety',
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
