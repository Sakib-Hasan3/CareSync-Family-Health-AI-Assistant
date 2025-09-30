/// App-wide string constants
class AppStrings {
  AppStrings._();

  // App info
  static const String appName = 'CareSync';
  static const String appDescription = 'Family Health Management App';

  // Auth strings
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String profiles = 'Profiles';
  static const String medications = 'Medications';
  static const String appointments = 'Appointments';
  static const String documents = 'Documents';
  static const String vitals = 'Vitals';
  static const String emergency = 'Emergency';
  static const String nearbyServices = 'Nearby Services';
  static const String aiAssistant = 'AI Assistant';
  static const String settings = 'Settings';

  // Dashboard
  static const String welcomeBack = 'Welcome back';
  static const String todaysOverview = "Today's Overview";
  static const String quickActions = 'Quick Actions';
  static const String recentActivity = 'Recent Activity';

  // Family members
  static const String familyMembers = 'Family Members';
  static const String addFamilyMember = 'Add Family Member';
  static const String name = 'Name';
  static const String dateOfBirth = 'Date of Birth';
  static const String relationship = 'Relationship';
  static const String bloodType = 'Blood Type';
  static const String allergies = 'Allergies';

  // Medications
  static const String medicationList = 'Medication List';
  static const String addMedication = 'Add Medication';
  static const String medicationName = 'Medication Name';
  static const String dosage = 'Dosage';
  static const String frequency = 'Frequency';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String instructions = 'Instructions';

  // Appointments
  static const String appointmentList = 'Appointments';
  static const String addAppointment = 'Add Appointment';
  static const String doctorName = 'Doctor Name';
  static const String appointmentDate = 'Appointment Date';
  static const String appointmentTime = 'Appointment Time';
  static const String location = 'Location';
  static const String notes = 'Notes';

  // Documents
  static const String documentList = 'Documents';
  static const String uploadDocument = 'Upload Document';
  static const String documentType = 'Document Type';
  static const String scanDocument = 'Scan Document';
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';

  // Vitals
  static const String vitalsInput = 'Enter Vitals';
  static const String vitalsHistory = 'Vitals History';
  static const String bloodPressure = 'Blood Pressure';
  static const String heartRate = 'Heart Rate';
  static const String temperature = 'Temperature';
  static const String weight = 'Weight';
  static const String height = 'Height';
  static const String bloodSugar = 'Blood Sugar';

  // Emergency
  static const String emergencyCard = 'Emergency Card';
  static const String emergencyContacts = 'Emergency Contacts';
  static const String medicalConditions = 'Medical Conditions';
  static const String currentMedications = 'Current Medications';
  static const String sosMode = 'SOS Mode';
  static const String callEmergency = 'Call Emergency';

  // General
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';

  // Error messages
  static const String errorGeneral = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please try again.';
  static const String errorValidation =
      'Please check your input and try again.';

  // Success messages
  static const String successSaved = 'Saved successfully';
  static const String successDeleted = 'Deleted successfully';
  static const String successUpdated = 'Updated successfully';
}
