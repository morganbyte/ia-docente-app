import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_application_1/config/app_theme.dart';
import 'package:flutter_application_1/ui/screens/login_screen.dart';
import 'package:flutter_application_1/ui/screens/plantilla_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EducaPro',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return const PlantillaScreen();
          }
          return const AuthenticationPage();
        },
      ),
      routes: {
        '/login': (context) => const AuthenticationPage(),
        '/plantilla': (context) => const PlantillaScreen(),
      },
    );
  }
}
