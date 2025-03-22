import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:pmu/screens/montee.dart';
import './screens/login_screen.dart'; 
import './screens/quick_links_imp.dart';
import './screens/register_screen.dart';
import 'screens/mentor_home.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAemrx4kVgEXWSrnNqxTFKXgvWkPWRPT2E",
          authDomain: "parking-pmu-app.firebaseapp.com",
          projectId: "parking-pmu-app",
          storageBucket: "parking-pmu-app.appspot.com",
          messagingSenderId: "633713268438",
          appId: "1:633713268438:web:c184fe816b14e42b4e5b77",
          measurementId: "G-B8CT35X2CV",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    runApp(const MyApp());
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PmuMentor App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/login', // Set your initial route
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/mentorHome':(context) => MentorHomeScreen(),
        '/resources': (context) => const ResourcesListScreen(),
        '/career': (context) => const CareerOpportunitiesListScreen(),
        // '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}


