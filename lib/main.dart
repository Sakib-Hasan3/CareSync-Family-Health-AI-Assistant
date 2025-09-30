import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'features/auth/welcome_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(CareSyncApp());
}

class CareSyncApp extends StatelessWidget {
  CareSyncApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/welcome',
    redirect: (BuildContext context, GoRouterState state) {
      final User? user = FirebaseAuth.instance.currentUser;
      final bool isLoggedIn = user != null;
      final bool isAuthRoute =
          state.uri.path.startsWith('/welcome') ||
          state.uri.path.startsWith('/login') ||
          state.uri.path.startsWith('/register');

      // If user is logged in and trying to access auth routes, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      // If user is not logged in and not on auth routes, redirect to welcome
      if (!isLoggedIn && !isAuthRoute) {
        return '/welcome';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CareSync',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      routerConfig: _router,
    );
  }
}
