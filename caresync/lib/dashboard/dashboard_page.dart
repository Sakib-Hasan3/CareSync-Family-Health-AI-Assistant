import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Use local Iconsax stub to avoid external dependency
import 'package:caresync/features/health_timeline/iconsax_stub.dart';

// Feature pages
import 'package:caresync/features/family_profiles/family_profiles_page.dart';
import 'package:caresync/features/medications/medications_page.dart';
import 'package:caresync/features/appointments/appointments_page.dart';
import 'package:caresync/features/ai_assistant/assistant_page.dart';
import 'package:caresync/features/emergency/emergency_profile_page.dart';
import 'package:caresync/features/family_profiles/family_repository.dart';
import 'package:caresync/features/medications/medication_repository.dart';
import 'package:caresync/features/medications/models/medication.dart';
import 'package:caresync/features/appointments/appointment_repository.dart';
import 'package:caresync/features/alerts/smart_alert_service.dart';
import 'package:caresync/features/blood/ui/blood_home_page.dart';
import 'package:caresync/features/blood/ui/donor_registration_page.dart';
import 'package:caresync/features/health_timeline/ui/health_timeline_page.dart';
import 'package:caresync/features/reports/ui/monthly_report_page.dart';
import 'package:caresync/features/emergency_contacts/ui/emergency_contacts_page.dart';

// Feature repositories
// Repositories can be injected/used within feature pages; not needed here.

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  // Dashboard-wide data is handled by DashboardHome; keep this class minimal.

  final List<Widget> _pages = [
    const DashboardHome(),
    const MedicationsPage(),
    const AppointmentsPage(),
    const HealthRecordsPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _selectedIndex == 0
          ? _buildFloatingActionButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2563EB).withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.home),
            selectedIcon: Icon(Iconsax.home_15),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.health),
            selectedIcon: Icon(Iconsax.health5),
            label: 'Meds',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.calendar),
            selectedIcon: Icon(Iconsax.calendar_25),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.document),
            selectedIcon: Icon(Iconsax.document5),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.profile_circle),
            selectedIcon: Icon(Iconsax.profile_circle5),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showQuickActionsMenu,
      backgroundColor: const Color(0xFF2563EB),
      child: const Icon(Iconsax.add, color: Colors.white, size: 28),
    );
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final maxHeight = MediaQuery.of(context).size.height * 0.72;
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Constrain the grid so it cannot grow beyond the available sheet height
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxHeight - 140),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        padding: EdgeInsets.zero,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _QuickActionGridItem(
                            icon: Iconsax.profile_add,
                            label: 'Add Family',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FamilyProfilesPage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.health,
                            label: 'Add Medication',
                            color: const Color(0xFF10B981),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MedicationsPage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.calendar_add,
                            label: 'Book Appointment',
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AppointmentsPage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.document_add,
                            label: 'Add Record',
                            color: const Color(0xFF2563EB),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HealthRecordsPage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.activity,
                            label: 'Track Symptoms',
                            color: const Color(0xFFEC4899),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SymptomTrackerPage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.cpu,
                            label: 'AI Assistant',
                            color: const Color(0xFF06B6D4),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AIAssistantPage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.profile_add,
                            label: 'Register Donor',
                            color: const Color(0xFF10B981),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DonorRegistrationPage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.blood_drop,
                            label: 'Blood Requests',
                            color: const Color(0xFFEF4444),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BloodHomePage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.activity,
                            label: 'Health Timeline',
                            color: const Color(0xFF2563EB),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HealthTimelinePage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.document,
                            label: 'Monthly Report',
                            color: const Color(0xFF2563EB),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MonthlyReportPage(),
                                ),
                              );
                            },
                          ),
                          _QuickActionGridItem(
                            icon: Iconsax.call_calling,
                            label: 'Emergency Helplines',
                            color: const Color(0xFFDC143C),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EmergencyContactsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  List<Map<String, dynamic>> _familyMembers = [];
  List<Map<String, dynamic>> _todayMedications = [];
  List<Map<String, dynamic>> _todayAppointments = [];
  Map<String, dynamic> _healthStats = {};
  bool _loading = true;

  final _familyRepo = FamilyRepository();
  final _medRepo = MedicationRepository();
  final _aptRepo = AppointmentRepository();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Load and summarize real data from repositories
    try {
      await _familyRepo.init();
      await _medRepo.init();
      await _aptRepo.init();
    } catch (_) {}

    final members = _familyRepo.getAll();
    final meds = _medRepo.getAll();
    final appts = _aptRepo.getAll();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // Family chips on dashboard
    final palette = const [
      Color(0xFF2563EB),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
    ];
    final famCards = <Map<String, dynamic>>[];
    for (int i = 0; i < members.length && i < 6; i++) {
      final m = members[i];
      final status = m.chronicDiseases.isNotEmpty
          ? 'Condition'
          : (m.allergies.isNotEmpty ? 'Allergy' : 'Good');
      famCards.add({
        'name': m.name,
        'role': m.bloodGroup.isNotEmpty ? m.bloodGroup : 'Member',
        'status': status,
        'color': palette[i % palette.length],
      });
    }

    // Today's meds by nextDose date, fallback to first 3
    List<Medication> todaysMeds = meds
        .where(
          (m) =>
              m.nextDose != null &&
              m.nextDose!.isAfter(todayStart) &&
              m.nextDose!.isBefore(todayEnd),
        )
        .toList();
    if (todaysMeds.isEmpty) {
      todaysMeds = meds.take(3).toList();
    }
    final medCards = todaysMeds
        .map(
          (m) => {
            'name': m.name,
            'dosage': m.dosage,
            'time': m.time.isNotEmpty ? m.time : _fmtTime(m.nextDose),
            'taken': false,
          },
        )
        .toList();

    // Today's appointments
    final todaysAppts = appts
        .where(
          (a) =>
              a.datetime.isAfter(todayStart) && a.datetime.isBefore(todayEnd),
        )
        .toList();
    final apptCards = todaysAppts
        .map(
          (a) => {
            'doctor': a.doctor,
            'specialty': a.specialty ?? '',
            'time': _fmtTime(a.datetime),
            'completed': a.isCompleted,
          },
        )
        .toList();

    setState(() {
      _familyMembers = famCards;
      _todayMedications = medCards;
      _todayAppointments = apptCards;
      _healthStats = {
        'familyMembers': members.length,
        'activeMeds': meds.length,
        'upcomingAppointments': appts
            .where((a) => a.datetime.isAfter(now))
            .length,
        'medicalRecords': 0,
        'symptomsTracked': 0,
      };
      _loading = false;
    });
    // Run smart alerts analysis in background (non-blocking)
    Future.microtask(() async {
      try {
        await SmartAlertService().analyzeAndAlert();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentTime = DateTime.now();
    final hour = currentTime.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _loading ? _buildLoadingState() : _buildDashboard(user, greeting),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your health dashboard...'),
        ],
      ),
    );
  }

  Widget _buildDashboard(User? user, String greeting) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(user, greeting),
              const SizedBox(height: 24),

              // Emergency Quick Access
              _buildEmergencyQuickAccess(),
              const SizedBox(height: 24),

              // Emergency Contacts Quick Access
              _buildEmergencyContactsCard(),
              const SizedBox(height: 24),

              // Health Overview Cards
              _buildHealthOverview(),
              const SizedBox(height: 24),

              // Quick Stats Row
              _buildQuickStats(),
              const SizedBox(height: 24),

              // Reports & Timeline quick access
              _buildReportsTimelineSection(),
              const SizedBox(height: 24),

              // Today's Medications
              if (_todayMedications.isNotEmpty) ...[
                _buildSectionHeader('Today\'s Medications', 'View All', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MedicationsPage()),
                  );
                }),
                const SizedBox(height: 12),
                _buildMedicationsList(),
                const SizedBox(height: 24),
              ],

              // Today's Appointments
              if (_todayAppointments.isNotEmpty) ...[
                _buildSectionHeader('Today\'s Appointments', 'View All', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppointmentsPage()),
                  );
                }),
                const SizedBox(height: 12),
                _buildAppointmentsList(),
                const SizedBox(height: 24),
              ],

              // Family Members
              _buildSectionHeader('Family Members', 'Manage', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FamilyProfilesPage()),
                );
              }),
              const SizedBox(height: 12),
              _buildFamilyMembers(),
              const SizedBox(height: 16),
              // Visible Blood donation card (register donor quick access)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DonorRegistrationPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.04),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Iconsax.profile_add,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Blood Donation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Register as a donor or request blood quickly',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DonorRegistrationPage(),
                            ),
                          );
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Health Tips with AI
              _buildAITips(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User? user, String greeting) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.displayName ?? user?.email?.split('@')[0] ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Emergency Button
            _HeaderIconButton(
              icon: Iconsax.heart,
              color: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmergencyProfilePage(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            // AI Assistant
            _HeaderIconButton(
              icon: Iconsax.cpu,
              color: const Color(0xFF06B6D4),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIAssistantPage()),
                );
              },
            ),
            const SizedBox(width: 8),
            // Notifications
            _HeaderIconButton(
              icon: Iconsax.notification,
              color: const Color(0xFF64748B),
              badge: true,
              onPressed: () {
                // Handle notifications
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyQuickAccess() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyProfilePage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(blurRadius: 12, color: Colors.red.withOpacity(0.3)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Iconsax.warning_2, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Access critical medical info offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyContactsPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDC143C), Color(0xFFFF6B6B)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(blurRadius: 12, color: Colors.red.withOpacity(0.3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Helplines',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ambulance, hospitals, police & more',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_enabled,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: const Color(0xFF2563EB).withOpacity(0.3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HealthMetric(
                value: _healthStats['familyMembers'].toString(),
                label: 'Family\nMembers',
                color: Colors.white,
              ),
              _HealthMetric(
                value: _healthStats['activeMeds'].toString(),
                label: 'Active\nMedications',
                color: Colors.white,
              ),
              _HealthMetric(
                value: _healthStats['upcomingAppointments'].toString(),
                label: 'Upcoming\nAppointments',
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last updated: Today',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'All Systems Good',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Iconsax.health,
            value:
                '${_todayMedications.where((med) => med['taken'] == true).length}/${_todayMedications.length}',
            label: 'Meds Taken',
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Iconsax.calendar_tick,
            value:
                '${_todayAppointments.where((apt) => apt['completed'] == true).length}/${_todayAppointments.length}',
            label: 'Appointments',
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Iconsax.activity,
            value: _healthStats['symptomsTracked'].toString(),
            label: 'Symptoms Tracked',
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    String action,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsList() {
    return Column(
      children: _todayMedications.map((medication) {
        return _MedicationCard(
          name: medication['name'],
          dosage: medication['dosage'],
          time: medication['time'],
          taken: medication['taken'],
          onTap: () {
            // Mark as taken/not taken (local UI toggle)
            setState(() {
              medication['taken'] = !medication['taken'];
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildAppointmentsList() {
    return Column(
      children: _todayAppointments.map((appointment) {
        return GestureDetector(
          onLongPress: () => Navigator.pushNamed(context, '/directory/admin'),
          child: _AppointmentCard(
            doctor: appointment['doctor'],
            specialty: appointment['specialty'],
            time: appointment['time'],
            completed: appointment['completed'],
            onTap: () {
              // Mark as completed
              setState(() {
                appointment['completed'] = !appointment['completed'];
              });
            },
          ),
        );
      }).toList(),
    );
  }

  String _fmtTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour;
    final m = dt.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h % 12 == 0 ? 12 : h % 12;
    return '$dh:${m.toString().padLeft(2, '0')} $period';
  }

  Widget _buildFamilyMembers() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._familyMembers.map((member) {
            return _FamilyMemberCard(
              name: member['name'],
              role: member['role'],
              color: member['color'],
              healthStatus: member['status'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FamilyProfilesPage()),
                );
              },
            );
          }),
          const SizedBox(width: 12),
          _AddMemberCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilyProfilesPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAITips() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIAssistantPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.cpu,
                color: Color(0xFF06B6D4),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Health Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Get personalized health tips and medication advice',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Try Now',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF06B6D4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTimelineSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HealthTimelinePage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.04),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.activity,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Health Timeline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'View your appointments, meds, labs and events',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyReportPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.04),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.document,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Monthly Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Generate and download your monthly health summary',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Supporting Widget Classes...

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool badge;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    required this.color,
    this.badge = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: IconButton(
        icon: badge
            ? Badge(
                smallSize: 8,
                backgroundColor: Colors.red,
                child: Icon(icon, color: color),
              )
            : Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _HealthMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final bool taken;
  final VoidCallback onTap;

  const _MedicationCard({
    required this.name,
    required this.dosage,
    required this.time,
    required this.taken,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: taken
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              taken ? Iconsax.tick_circle : Iconsax.clock,
              color: taken ? const Color(0xFF10B981) : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dosage • $time',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              taken ? Iconsax.undo : Iconsax.tick_circle,
              color: taken ? Colors.grey : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctor;
  final String specialty;
  final String time;
  final bool completed;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.doctor,
    required this.specialty,
    required this.time,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              completed ? Iconsax.tick_circle : Iconsax.calendar,
              color: completed
                  ? const Color(0xFF10B981)
                  : const Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$specialty • $time',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              completed ? Iconsax.undo : Iconsax.tick_circle,
              color: completed ? Colors.grey : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final Color color;
  final String healthStatus;
  final VoidCallback onTap;

  const _FamilyMemberCard({
    required this.name,
    required this.role,
    required this.color,
    required this.healthStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.profile_circle, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: double.infinity,
              child: Text(
                role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: healthStatus == 'Good'
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                healthStatus,
                style: TextStyle(
                  fontSize: 9,
                  color: healthStatus == 'Good'
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMemberCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMemberCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Flutter doesn't support dashed borders natively; use solid border here.
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.add, color: Colors.grey.shade400, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Member',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionGridItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages for other features
class HealthRecordsPage extends StatelessWidget {
  const HealthRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      body: const Center(child: Text('Health Records Page')),
    );
  }
}

// Minimal Profile page placeholder for bottom navigation
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Page')),
    );
  }
}

class SymptomTrackerPage extends StatelessWidget {
  const SymptomTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Tracker')),
      body: const Center(child: Text('Symptom Tracker Page')),
    );
  }
}

class AIAssistantPage extends StatelessWidget {
  const AIAssistantPage({super.key});
  @override
  Widget build(BuildContext context) => const AssistantPage();
}

// Keep your existing MedicationsPage, AppointmentsPage, ProfilePage classes...
