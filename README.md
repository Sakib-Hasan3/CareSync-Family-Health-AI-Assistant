<<<<<<< HEAD
# 🏥 CareSync - Family Health Management App

CareSync is a comprehensive Flutter application designed to help families manage their health effectively. Track medications, schedule appointments, monitor family members' health, and access emergency services - all in one place.

## ✨ Key Features

### 👨‍👩‍👧‍👦 Family Health Management
- **Family Profiles**: Create and manage health profiles for all family members
- **Health Timeline**: Visual timeline of all health events, appointments, and medications
- **Medical Records**: Store and organize medical documents securely
- **Chronic Disease Tracking**: Monitor ongoing health conditions and allergies

### 💊 Medication Management
- **Smart Reminders**: Never miss a dose with intelligent medication reminders
- **Dosage Tracking**: Track medication schedules and remaining quantities
- **Refill Alerts**: Get notified when medications are running low
- **Medication Safety**: AI-powered guidance on medication interactions

### 📅 Appointment Scheduling
- **Calendar Integration**: Schedule and track medical appointments
- **Doctor Directory**: Manage your healthcare providers
- **Appointment Reminders**: Automated notifications for upcoming visits
- **Visit History**: Keep records of past appointments and outcomes

### 🩸 Blood Donation System
- **Donor Registration**: Register as a blood donor with availability status
- **Blood Requests**: Create and respond to urgent blood requests
- **Donor Search**: Find blood donors by blood group and location
- **Donation History**: Track last donation date and eligibility

### 🚨 Emergency Features
- **Emergency Profile**: Quick access to critical medical information offline
- **Emergency Contacts**: 14+ pre-configured emergency helplines
  - Ambulance Services (102, 999)
  - Police Emergency (100)
  - Fire Service (101)
  - Mental Health Helpline
  - Poison Control Center
  - Women & Child Helplines
  - And more...
- **One-Tap Calling**: Direct phone dialing for emergency services
- **Favorites & Recent Calls**: Quick access to frequently used contacts

### 🤖 AI Health Assistant (Gemini API)
- **24/7 Health Guidance**: Get instant answers to health questions
- **Symptom Analysis**: AI-powered symptom checker and guidance
- **Medication Information**: Safety tips and drug interaction warnings
- **First Aid Instructions**: Step-by-step emergency care guidance
- **Offline Mode**: Access offline health guides when internet is unavailable
- **Medical Disclaimer**: Professional medical disclaimer with every response

### 📊 Reports & Analytics
- **Monthly Health Reports**: Generate comprehensive health summaries
- **PDF Export**: Download and share health reports
- **Health Insights**: Track trends and patterns in your health data
- **Smart Alerts**: Intelligent notifications for health concerns

## 🛠️ Technical Features

### Architecture
- **Clean Architecture**: Separation of concerns with feature-based structure
- **Repository Pattern**: Abstracted data layer for easy testing
- **State Management**: Stateful widgets with reactive UI updates
- **Local Storage**: Hive database for offline-first functionality

### Security & Privacy
- **Encrypted Storage**: Sensitive data protected with flutter_secure_storage
- **Firebase Authentication**: Secure user authentication
- **Cloud Firestore**: Real-time data synchronization
- **Offline Access**: Critical information available without internet

### Key Packages
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Backend & Auth
- `hive`, `hive_flutter` - Local database
- `google_generative_ai` - AI Assistant
- `url_launcher` - Emergency calling functionality
- `flutter_local_notifications` - Smart reminders
- `pdf` - Report generation
- `image_picker`, `file_picker` - Document management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Sakib-Hasan3/CareSync-Family-Health-App.git
   cd CareSync-Family-Health-App/caresync
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. **Set up AI Assistant (Optional)**
 4. **Set up AI Assistant (Optional)**

    The app supports using an AI service key (Google Gemini, Deepseek, or other OpenAI-compatible keys).

    - Recommended (development): provide the key at runtime or via secure storage in the app settings.

    - Run with API key:
       ```bash
       flutter run --dart-define=GEMINI_API_KEY=your_key_here
       ```

    - Build release with API key (not recommended for production builds):
       ```bash
       flutter build apk --dart-define=GEMINI_API_KEY=your_key_here
       ```

    - For production, host a small backend proxy that holds the API key and forwards requests from the app. This avoids shipping secrets in client binaries.

    *Note: Without an API key, the app will use offline health guides from `assets/guides/`*

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── auth/                    # Authentication pages
├── dashboard/               # Main dashboard & home
├── features/
│   ├── ai_assistant/       # AI health assistant
│   ├── appointments/       # Appointment scheduling
│   ├── blood/             # Blood donation system
│   ├── emergency/         # Emergency profile
│   ├── emergency_contacts/ # Emergency helplines
│   ├── family_profiles/   # Family member management
│   ├── health_timeline/   # Health event timeline
│   ├── medications/       # Medication tracking
│   ├── reports/           # Health reports & PDF
│   └── alerts/            # Smart alert system
├── shared/                 # Shared widgets & utilities
└── main.dart              # App entry point

assets/
├── guides/                 # Offline AI health guides
│   ├── first_aid.json
│   ├── symptoms.json
│   └── medication_safety.json
└── sounds/                 # Notification sounds
```

## 🎯 Usage

### For Families
1. **Create Family Profiles**: Add all family members with their health details
2. **Set Medication Reminders**: Never miss a dose with smart notifications
3. **Schedule Appointments**: Keep track of all medical visits
4. **Emergency Access**: Store critical info for emergency situations

### For Blood Donors
1. **Register**: Sign up as a blood donor with your details
2. **Update Availability**: Mark yourself available/unavailable
3. **Respond to Requests**: Help save lives by responding to blood needs

### For Emergency Situations
1. **Quick Access**: Tap emergency card on dashboard
2. **One-Tap Calling**: Call ambulance, police, or other services instantly
3. **Emergency Profile**: Show critical medical info to first responders

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Contact

For questions or support, please contact the development team or open an issue on GitHub.

## ⚠️ Medical Disclaimer

CareSync is a health management tool and does not provide medical advice. Always consult with qualified healthcare professionals for medical decisions. The AI assistant is for informational purposes only and should not replace professional medical consultation.

## 🙏 Acknowledgments

- Firebase for backend infrastructure
- Google Gemini AI for health assistant capabilities
- Flutter team for the amazing framework
- All open-source contributors

---

**Built with ❤️ using Flutter**
=======
# 🏥 CareSync - Family Health Management App

CareSync is a comprehensive Flutter application designed to help families manage their health effectively. Track medications, schedule appointments, monitor family members' health, and access emergency services - all in one place.

## ✨ Key Features

### 👨‍👩‍👧‍👦 Family Health Management
- **Family Profiles**: Create and manage health profiles for all family members
- **Health Timeline**: Visual timeline of all health events, appointments, and medications
- **Medical Records**: Store and organize medical documents securely
- **Chronic Disease Tracking**: Monitor ongoing health conditions and allergies

### 💊 Medication Management
- **Smart Reminders**: Never miss a dose with intelligent medication reminders
- **Dosage Tracking**: Track medication schedules and remaining quantities
- **Refill Alerts**: Get notified when medications are running low
- **Medication Safety**: AI-powered guidance on medication interactions

### 📅 Appointment Scheduling
- **Calendar Integration**: Schedule and track medical appointments
- **Doctor Directory**: Manage your healthcare providers
- **Appointment Reminders**: Automated notifications for upcoming visits
- **Visit History**: Keep records of past appointments and outcomes

### 🩸 Blood Donation System
- **Donor Registration**: Register as a blood donor with availability status
- **Blood Requests**: Create and respond to urgent blood requests
- **Donor Search**: Find blood donors by blood group and location
- **Donation History**: Track last donation date and eligibility

### 🚨 Emergency Features
- **Emergency Profile**: Quick access to critical medical information offline
- **Emergency Contacts**: 14+ pre-configured emergency helplines
  - Ambulance Services (102, 999)
  - Police Emergency (100)
  - Fire Service (101)
  - Mental Health Helpline
  - Poison Control Center
  - Women & Child Helplines
  - And more...
- **One-Tap Calling**: Direct phone dialing for emergency services
- **Favorites & Recent Calls**: Quick access to frequently used contacts

### 🤖 AI Health Assistant (Gemini API)
- **24/7 Health Guidance**: Get instant answers to health questions
- **Symptom Analysis**: AI-powered symptom checker and guidance
- **Medication Information**: Safety tips and drug interaction warnings
- **First Aid Instructions**: Step-by-step emergency care guidance
- **Offline Mode**: Access offline health guides when internet is unavailable
- **Medical Disclaimer**: Professional medical disclaimer with every response

### 📊 Reports & Analytics
- **Monthly Health Reports**: Generate comprehensive health summaries
- **PDF Export**: Download and share health reports
- **Health Insights**: Track trends and patterns in your health data
- **Smart Alerts**: Intelligent notifications for health concerns

## 🛠️ Technical Features

### Architecture
- **Clean Architecture**: Separation of concerns with feature-based structure
- **Repository Pattern**: Abstracted data layer for easy testing
- **State Management**: Stateful widgets with reactive UI updates
- **Local Storage**: Hive database for offline-first functionality

### Security & Privacy
- **Encrypted Storage**: Sensitive data protected with flutter_secure_storage
- **Firebase Authentication**: Secure user authentication
- **Cloud Firestore**: Real-time data synchronization
- **Offline Access**: Critical information available without internet

### Key Packages
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Backend & Auth
- `hive`, `hive_flutter` - Local database
- `google_generative_ai` - AI Assistant
- `url_launcher` - Emergency calling functionality
- `flutter_local_notifications` - Smart reminders
- `pdf` - Report generation
- `image_picker`, `file_picker` - Document management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Sakib-Hasan3/CareSync-Family-Health-App.git
   cd CareSync-Family-Health-App/caresync
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. **Set up AI Assistant (Optional)**
   
   Get a Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   
   Run with API key:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```
   
   Build release with API key:
   ```bash
   flutter build apk --dart-define=GEMINI_API_KEY=your_key_here
   ```
   
   *Note: Without an API key, the app will use offline health guides from `assets/guides/`*

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── auth/                    # Authentication pages
├── dashboard/               # Main dashboard & home
├── features/
│   ├── ai_assistant/       # AI health assistant
│   ├── appointments/       # Appointment scheduling
│   ├── blood/             # Blood donation system
│   ├── emergency/         # Emergency profile
│   ├── emergency_contacts/ # Emergency helplines
│   ├── family_profiles/   # Family member management
│   ├── health_timeline/   # Health event timeline
│   ├── medications/       # Medication tracking
│   ├── reports/           # Health reports & PDF
│   └── alerts/            # Smart alert system
├── shared/                 # Shared widgets & utilities
└── main.dart              # App entry point

assets/
├── guides/                 # Offline AI health guides
│   ├── first_aid.json
│   ├── symptoms.json
│   └── medication_safety.json
└── sounds/                 # Notification sounds
```

## 🎯 Usage

### For Families
1. **Create Family Profiles**: Add all family members with their health details
2. **Set Medication Reminders**: Never miss a dose with smart notifications
3. **Schedule Appointments**: Keep track of all medical visits
4. **Emergency Access**: Store critical info for emergency situations

### For Blood Donors
1. **Register**: Sign up as a blood donor with your details
2. **Update Availability**: Mark yourself available/unavailable
3. **Respond to Requests**: Help save lives by responding to blood needs

### For Emergency Situations
1. **Quick Access**: Tap emergency card on dashboard
2. **One-Tap Calling**: Call ambulance, police, or other services instantly
3. **Emergency Profile**: Show critical medical info to first responders

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Contact

For questions or support, please contact the development team or open an issue on GitHub.

## ⚠️ Medical Disclaimer

CareSync is a health management tool and does not provide medical advice. Always consult with qualified healthcare professionals for medical decisions. The AI assistant is for informational purposes only and should not replace professional medical consultation.

## 🙏 Acknowledgments

- Firebase for backend infrastructure
- Google Gemini AI for health assistant capabilities
- Flutter team for the amazing framework
- All open-source contributors

---

**Built with ❤️ using Flutter**

>>>>>>> 708022920982b0a6f5b0024c4b12d82baa6f60ef
