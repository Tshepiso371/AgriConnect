import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/crop_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/login_screen.dart';
import 'screens/crop_list_screen.dart';
import 'services/auth_service.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // :white_check_mark: AUTO LOGIN LOGIC
        home: FutureBuilder(
          future: authService.getUser(),
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // No user → go to login
            if (!snapshot.hasData) {
              return LoginScreen();
            }

            // User exists → go to correct role
            final user = snapshot.data as Map<String, String>;

            if (user['role'] == 'farmer') {
              return const CropListScreen();
            } else {
              return const CropListScreen();
            }
          },
        ),

        // :white_check_mark: KEEP ROUTES (for navigation like logout)
        routes: {

          '/farmer': (context) => const CropListScreen(),
          '/buyer': (context) => const CropListScreen(),
          '/signup': (context) => const SignUpScreen(),

        },
      ),
    );
  }
}