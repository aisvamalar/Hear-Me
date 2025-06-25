import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:music_recommender/views/splash_screen.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';  // Make sure you import your signup screen
import 'views/home/home_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Firebase already initialized, continue
      print('Firebase already initialized');
    } else {
      rethrow;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Music Recommender',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
        // Define named routes for easier navigation
        routes: {
          '/splash': (context) =>  SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) =>  SignUpScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return  SplashScreen();
    }

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Navigate based on authentication state
        if (authViewModel.isSignedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}