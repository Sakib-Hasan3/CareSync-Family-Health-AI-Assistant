import 'package:flutter/material.dart';
import 'auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  bool _googleLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStats(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Everything You Need'),
                  const SizedBox(height: 16),
                  _buildFeatureGrid(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Loved by Families'),
                  const SizedBox(height: 16),
                  _buildTestimonials(),
                  const SizedBox(height: 36),
                  _buildAuthButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF0891B2)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CareSync',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Your Family Health,\nPerfectly Synced.',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Manage medications, track health records, and coordinate care for your entire family in one secure place.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.82),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _HeroPill(icon: Icons.medication_rounded, label: 'Smart Meds'),
                  _HeroPill(icon: Icons.family_restroom, label: 'Family Care'),
                  _HeroPill(icon: Icons.sos_rounded, label: 'SOS Alert'),
                  _HeroPill(icon: Icons.vaccines_rounded, label: 'Vaccines'),
                  _HeroPill(icon: Icons.smart_toy_outlined, label: 'AI Doctor'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '10K+', label: 'Families'),
          _StatDivider(),
          _StatItem(value: '50K+', label: 'Meds Tracked'),
          _StatDivider(),
          _StatItem(value: '1K+', label: 'Lives Saved'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
        letterSpacing: -0.4,
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      (Icons.medication_rounded, 'Medication\nTracker', const Color(0xFF2563EB)),
      (Icons.folder_special_rounded, 'Health\nRecords', const Color(0xFF10B981)),
      (Icons.family_restroom_rounded, 'Family\nProfiles', const Color(0xFF8B5CF6)),
      (Icons.warning_amber_rounded, 'Emergency\nProfile', const Color(0xFFEF4444)),
      (Icons.bloodtype_rounded, 'Blood\nDonation', const Color(0xFFDC2626)),
      (Icons.smart_toy_rounded, 'AI\nAssistant', const Color(0xFF0891B2)),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: features
          .map(
            (f) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: f.$3.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(f.$1, color: f.$3, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    f.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTestimonials() {
    return SizedBox(
      height: 170,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _TestimonialCard(
            name: 'Sarah M.',
            role: 'Mother of 3',
            rating: 5,
            comment: "CareSync saved me so much time managing my family's medications. The SOS feature is a lifesaver!",
            avatarColor: Color(0xFF2563EB),
          ),
          SizedBox(width: 14),
          _TestimonialCard(
            name: 'Dr. Raj Patel',
            role: 'Family Physician',
            rating: 5,
            comment: 'I recommend CareSync to all my patients. Emergency profiles provide critical info when it matters most.',
            avatarColor: Color(0xFF10B981),
          ),
          SizedBox(width: 14),
          _TestimonialCard(
            name: 'The Johnson Family',
            role: 'Users for 2 years',
            rating: 5,
            comment: "From elderly parents to kids' vaccinations, CareSync keeps our whole family organized and healthy.",
            avatarColor: Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        // Google Sign-In button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _googleLoading ? null : _signInWithGoogle,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E293B),
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.08),
            ),
            child: _googleLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(Color(0xFF4285F4)),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GoogleIcon(),
                      const SizedBox(width: 12),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          icon: const Icon(Icons.login_rounded),
          label: const Text('Login to Your Account'),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Create New Account'),
        ),
      ],
    );
  }

  Widget _GoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2563EB),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: const Color(0xFFF1F5F9));
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
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star_rounded,
                size: 14,
                color: i < rating ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              comment,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarColor.withOpacity(0.18),
                child: Icon(Icons.person_rounded, color: avatarColor, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
