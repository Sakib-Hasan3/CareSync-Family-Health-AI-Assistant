import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(),
                const SizedBox(height: 40),

                // Hero Image/Illustration
                _buildHeroSection(size),
                const SizedBox(height: 50),

                // User Testimonials
                _buildTestimonialsSection(),
                const SizedBox(height: 40),

                // Feature Highlights
                _buildFeatureGrid(),
                const SizedBox(height: 40),

                // CTA Buttons
                _buildAuthButtons(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo/App Name
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.health_and_safety,
                color: Color(0xFF2563EB),
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'CareSync',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Tagline
        const Text(
          'Your Family Health,\nPerfectly Synced',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        // Description
        Text(
          'Manage medications, track health records, and coordinate care for your entire family in one secure place.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(Size size) {
    return Container(
      height: size.height * 0.3,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFF0FDF4)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            bottom: 20,
            child: Icon(
              Icons.family_restroom,
              size: 100,
              color: Colors.blue.shade100,
            ),
          ),
          const Positioned(
            left: 24,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medication, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Medication Tracker',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Appointment Manager',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.emergency, color: Color(0xFFEF4444), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Emergency Profiles',
                      style: TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildTestimonialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loved by Families',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'See what our users say about their experience',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        // Testimonials Carousel
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              SizedBox(width: 8),
              _TestimonialCard(
                name: 'Sarah M.',
                role: 'Mother of 3',
                rating: 5,
                comment:
                    'CareSync saved me so much time managing my family\'s medications and appointments. The blood donation feature helped us find a donor during an emergency!',
                avatarColor: Colors.blue,
              ),
              SizedBox(width: 16),
              _TestimonialCard(
                name: 'Dr. Raj Patel',
                role: 'Family Physician',
                rating: 5,
                comment:
                    'As a doctor, I recommend CareSync to all my patients. The emergency profiles provide critical information when it matters most.',
                avatarColor: Colors.green,
              ),
              SizedBox(width: 16),
              _TestimonialCard(
                name: 'The Johnson Family',
                role: 'Users for 2 years',
                rating: 5,
                comment:
                    'From tracking our elderly parents\' health to managing our kids\' vaccination schedules - CareSync keeps our entire family healthy and organized.',
                avatarColor: Colors.purple,
              ),
              SizedBox(width: 8),
            ],
          ),
        ),

        // Stats Row
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: '10K+', label: 'Families\nConnected'),
              _StatItem(value: '50K+', label: 'Medications\nManaged'),
              _StatItem(value: '1K+', label: 'Lives Saved\nvia Blood Donation'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Everything You Need',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Comprehensive health management tools for your family',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.medication_outlined,
                title: 'Medication\nTracker',
                color: Colors.blue,
                description: 'Never miss a dose with smart reminders',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.health_and_safety_outlined,
                title: 'Health\nRecords',
                color: Colors.green,
                description: 'Secure digital health records storage',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.family_restroom_outlined,
                title: 'Family\nProfiles',
                color: Colors.purple,
                description: 'Manage health for all family members',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.emergency_share_outlined,
                title: 'Emergency\nAccess',
                color: Colors.red,
                description: 'Critical info available offline',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.bloodtype_outlined,
                title: 'Blood\nDonation',
                color: Colors.deepOrange,
                description: 'Find donors and save lives',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.analytics_outlined,
                title: 'Health\nAnalytics',
                color: Colors.teal,
                description: 'Track trends and get insights',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        // Login Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Login to Your Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Register Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFF2563EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Create New Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // Guest Option
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            // Handle guest access
          },
          child: Text(
            'Continue as Guest',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final int rating;
  final String comment;
  final Color avatarColor;

  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.rating,
    required this.comment,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 16,
                color: index < rating
                    ? const Color(0xFFFFD700)
                    : Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Comment
          Flexible(
            child: Text(
              comment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          // User Info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avatarColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: avatarColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
