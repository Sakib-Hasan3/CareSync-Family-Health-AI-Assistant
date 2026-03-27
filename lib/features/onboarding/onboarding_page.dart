import 'package:flutter/material.dart';
import 'package:caresync/shared/app_settings.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardStep(
      gradient: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
      icon: Icons.health_and_safety_rounded,
      title: 'Welcome to CareSync',
      body:
          'Your all-in-one family health companion. Track medications, manage records, and coordinate care — all in one secure place.',
    ),
    _OnboardStep(
      gradient: [Color(0xFF059669), Color(0xFF10B981)],
      icon: Icons.medication_rounded,
      title: 'Never Miss a Dose',
      body:
          'Set up smart medication reminders. CareSync says "Good morning! Take Metformin with breakfast" so you never forget.',
    ),
    _OnboardStep(
      gradient: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
      icon: Icons.family_restroom_rounded,
      title: 'Your Whole Family',
      body:
          'Create profiles for every family member — each color-coded for quick recognition. From grandma\'s prescriptions to baby\'s vaccines.',
    ),
    _OnboardStep(
      gradient: [Color(0xFFDC2626), Color(0xFFEF4444)],
      icon: Icons.sos_rounded,
      title: 'Emergency Ready',
      body:
          'One-tap SOS alert sends your location to emergency contacts. Your medical ID is always available — even offline.',
    ),
    _OnboardStep(
      gradient: [Color(0xFF0891B2), Color(0xFF0EA5E9)],
      icon: Icons.smart_toy_rounded,
      title: 'AI Health Assistant',
      body:
          'Ask our AI anything — drug interactions, symptoms, nutrition plans. Powered by Gemini, available 24/7.',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await AppSettings().setOnboardingDone();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _OnboardingCard(step: _pages[i]),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Column(
                children: [
                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      if (_page < _pages.length - 1)
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E293B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _page == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardStep {
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String body;

  const _OnboardStep({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardStep step;
  const _OnboardingCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: step.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 60, 32, 140),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  size: size.width * 0.18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                step.body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
