import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'CareSync',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(context, Icons.person, 'Profiles', Colors.orange),
            _buildCard(context, Icons.medical_services, 'Medications', Colors.purple),
            _buildCard(context, Icons.calendar_today, 'Appointments', Colors.indigo),
            _buildCard(context, Icons.folder, 'Documents', Colors.blue),
            _buildCard(context, Icons.monitor_heart, 'Vitals', Colors.red),
            _buildCard(context, Icons.map, 'Nearby Services', Colors.green),
            _buildCard(context, Icons.emergency, 'SOS', Colors.black),
            _buildCard(context, Icons.chat_bubble, 'AI Assistant', Colors.cyan),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Login',
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        if (label == 'Profiles') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        }
        // TODO: Add navigation for other cards
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 28,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}
