import 'package:flutter/material.dart';
import '../features/welcome/welcome_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profiles/profile_screen.dart';
import '../features/profiles/add_family_member_screen.dart';
import '../features/medications/medication_list_screen.dart';
import '../features/medications/add_medication_screen.dart';
import '../features/appointments/appointment_list_screen.dart';
import '../features/appointments/add_appointment_screen.dart';
import '../features/documents/document_list_screen.dart';
import '../features/documents/upload_document_screen.dart';
import '../features/vitals/vitals_input_screen.dart';
import '../features/vitals/vitals_trend_screen.dart';
import '../features/emergency/emergency_card_screen.dart';
import '../features/emergency/sos_screen.dart';
import '../features/maps/nearby_services_screen.dart';
import '../features/ai_assistant/ai_chat_screen.dart';
import '../features/settings/settings_screen.dart';

/// App router configuration
class AppRouter {
  static const String initial = '/welcome';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String addFamilyMember = '/add-family-member';
  static const String medicationList = '/medication-list';
  static const String addMedication = '/add-medication';
  static const String appointmentList = '/appointment-list';
  static const String addAppointment = '/add-appointment';
  static const String documentList = '/document-list';
  static const String uploadDocument = '/upload-document';
  static const String vitalsInput = '/vitals-input';
  static const String vitalsTrend = '/vitals-trend';
  static const String emergencyCard = '/emergency-card';
  static const String sos = '/sos';
  static const String nearbyServices = '/nearby-services';
  static const String aiChat = '/ai-chat';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case addFamilyMember:
        return MaterialPageRoute(
          builder: (_) => const AddFamilyMemberScreen(),
          settings: settings,
        );
      case medicationList:
        return MaterialPageRoute(
          builder: (_) => const MedicationListScreen(),
          settings: settings,
        );
      case addMedication:
        return MaterialPageRoute(
          builder: (_) => const AddMedicationScreen(),
          settings: settings,
        );
      case appointmentList:
        return MaterialPageRoute(
          builder: (_) => const AppointmentListScreen(),
          settings: settings,
        );
      case addAppointment:
        return MaterialPageRoute(
          builder: (_) => const AddAppointmentScreen(),
          settings: settings,
        );
      case documentList:
        return MaterialPageRoute(
          builder: (_) => const DocumentListScreen(),
          settings: settings,
        );
      case uploadDocument:
        return MaterialPageRoute(
          builder: (_) => const UploadDocumentScreen(),
          settings: settings,
        );
      case vitalsInput:
        return MaterialPageRoute(
          builder: (_) => const VitalsInputScreen(),
          settings: settings,
        );
      case vitalsTrend:
        return MaterialPageRoute(
          builder: (_) => const VitalsTrendScreen(),
          settings: settings,
        );
      case emergencyCard:
        return MaterialPageRoute(
          builder: (_) => const EmergencyCardScreen(),
          settings: settings,
        );
      case sos:
        return MaterialPageRoute(
          builder: (_) => const SosScreen(),
          settings: settings,
        );
      case nearbyServices:
        return MaterialPageRoute(
          builder: (_) => const NearbyServicesScreen(),
          settings: settings,
        );
      case aiChat:
        return MaterialPageRoute(
          builder: (_) => const AiChatScreen(),
          settings: settings,
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('The page you are looking for does not exist.'),
            ),
          ),
        );
    }
  }
}
