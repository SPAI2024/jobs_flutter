import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import for web check
import 'package:jobs_flutter/pages/auth_page.dart';
import 'package:jobs_flutter/pages/home_page.dart';

import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jobs App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: kIsWeb
          ? HomePage() // Direct to HomePage for web platform
          : FutureBuilder<bool>( // Auth check for mobile platforms
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          // While checking auth status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // If error occurred
          if (snapshot.hasError) {
            return const AuthPage(); // Default to auth page on error
          }

          // Check if logged in
          bool isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? HomePage() : const AuthPage();
        },
      ),
    );
  }
}