import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

/// Welcome/Onboarding screen for new users
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to CareSync',
      subtitle: 'Your Family Health Management App',
      description:
          'Take control of your family\'s health with our comprehensive health tracking and management platform.',
      image: '🏥',
      gradient: [Colors.blue.shade400, Colors.blue.shade600],
    ),
    OnboardingPage(
      title: 'Track Health Records',
      subtitle: 'Digital Health Records',
      description:
          'Store and organize medical documents, prescriptions, lab results, and health records securely in one place.',
      image: '📋',
      gradient: [Colors.green.shade400, Colors.green.shade600],
    ),
    OnboardingPage(
      title: 'Medication Management',
      subtitle: 'Never Miss a Dose',
      description:
          'Set reminders for medications, track dosages, and manage prescriptions for all family members.',
      image: '💊',
      gradient: [Colors.purple.shade400, Colors.purple.shade600],
    ),
    OnboardingPage(
      title: 'Appointment Scheduling',
      subtitle: 'Stay Organized',
      description:
          'Schedule and track medical appointments, receive reminders, and manage healthcare visits efficiently.',
      image: '📅',
      gradient: [Colors.orange.shade400, Colors.orange.shade600],
    ),
    OnboardingPage(
      title: 'Health Monitoring',
      subtitle: 'Track Vital Signs',
      description:
          'Monitor blood pressure, heart rate, weight, and other vital signs with easy-to-read charts and trends.',
      image: '❤️',
      gradient: [Colors.red.shade400, Colors.red.shade600],
    ),
    OnboardingPage(
      title: 'Emergency Preparedness',
      subtitle: 'Always Ready',
      description:
          'Quick access to emergency contacts, medical information, and nearby healthcare services when you need them most.',
      image: '🚨',
      gradient: [Colors.teal.shade400, Colors.teal.shade600],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _pages[_currentPage].gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CareSync',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: _skipToEnd,
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        page.image,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            Text(
              page.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              page.subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              page.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: 32),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          OutlinedButton(
            onPressed: _previousPage,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Previous'),
          )
        else
          const SizedBox(width: 80),

        if (_currentPage < _pages.length - 1)
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _pages[_currentPage].gradient[1],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Next'),
          )
        else
          ElevatedButton(
            onPressed: _getStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _pages[_currentPage].gradient[1],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Get Started'),
          ),
      ],
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _getStarted() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final List<Color> gradient;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.gradient,
  });
}
