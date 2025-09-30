import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareSync Firebase Test',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const FirebaseTestScreen(),
    );
  }
}

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Testing Firebase connection...';
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _testFirebase();
  }

  Future<void> _testFirebase() async {
    try {
      // Test Firebase Core
      FirebaseApp app = Firebase.app();
      setState(() {
        _status =
            '✅ Firebase Core: Connected\\n'
            'App Name: ${app.name}\\n'
            'Project ID: ${app.options.projectId}\\n';
      });

      // Test Firebase Auth
      FirebaseAuth auth = FirebaseAuth.instance;
      _user = auth.currentUser;

      setState(() {
        _status += '\\n✅ Firebase Auth: Ready\\n';
        if (_user != null) {
          _status += 'Logged in as: ${_user!.email}\\n';
        } else {
          _status += 'No user logged in\\n';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Firebase Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAnonymousLogin() async {
    setState(() {
      _isLoading = true;
      _status += '\\n🔄 Testing anonymous login...\\n';
    });

    try {
      UserCredential result = await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _user = result.user;
        _status += '✅ Anonymous login successful!\\n';
        _status += 'User ID: ${_user!.uid}\\n';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status += '❌ Anonymous login failed: $e\\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _user = null;
        _status += '\\n✅ Signed out successfully\\n';
      });
    } catch (e) {
      setState(() {
        _status += '\\n❌ Sign out failed: $e\\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Firebase Test'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Firebase Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Text(
                        _status,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isLoading) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Authentication Test',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_user == null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _testAnonymousLogin,
                            icon: const Icon(Icons.person),
                            label: const Text('Test Anonymous Login'),
                          ),
                        ),
                      ] else ...[
                        Text(
                          '✅ Logged in as: ${_user!.isAnonymous ? 'Anonymous User' : _user!.email}',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CareSync is ready for development!\\n'
                        'Firebase services are configured and working.',
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
