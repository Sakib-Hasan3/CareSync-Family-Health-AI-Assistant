Family Health Profiles feature

Files:
- family_member.dart - model with Hive annotations (requires code generation)
- family_repository.dart - simple Hive-backed CRUD
- family_profiles_page.dart - list UI
- edit_family_member_page.dart - add/edit form UI

Setup:
1. Add dependencies (already added to project): hive, hive_flutter, path_provider
2. Register the adapter and initialize Hive in `main.dart` before running the app. Example:

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'features/family_profiles/family_member.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FamilyMemberAdapter());
  runApp(const MyApp());
}
```

3. Generate the adapter:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Usage:
- Import `features/family_profiles/family_profiles_page.dart` and navigate to it from your app.

Notes:
- The generated file `family_member.g.dart` will be created by build_runner.
- This feature stores data locally using Hive and works offline.
