## CareSync

CareSync is a Flutter app for managing family health: medications, appointments, and more.

### AI Health Assistant (Gemini API)

This project includes an AI Health Assistant with:

- Symptom guidance, medication safety tips, first aid steps, and health education
- Medical disclaimer shown with every answer
- Offline fallback guides when internet is unavailable or the API key is missing

To enable online AI responses, provide a Gemini API key at build/run time using a Dart define.

Windows PowerShell example:

```
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

Release build example:

```
flutter build apk --dart-define=GEMINI_API_KEY=your_key_here
```

If you omit the key or are offline, the assistant will use offline guides from `assets/guides/`.

### Assets

Offline guides are declared in `pubspec.yaml` and stored under `assets/guides/`:

- `first_aid.json`
- `symptoms.json`
- `medication_safety.json`

### Development

Run from the app root folder (`caresync/`):

```
flutter pub get
flutter run
```
