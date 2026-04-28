import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/crop_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/login_screen.dart';
import 'screens/crop_list_screen.dart';
import 'services/auth_service.dart';
import 'screens/signup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        title: 'AgriConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),

        // AUTO LOGIN LOGIC
        home: FutureBuilder<Map<String, dynamic>?>(
          future: authService.getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // No user found or error → Login
            if (!snapshot.hasData || snapshot.data == null) {
              return const LoginScreen();
            }

            // User exists → Crop List
            return const CropListScreen();
          },
        ),

        routes: {
          '/farmer': (context) => const CropListScreen(),
          '/buyer': (context) => const CropListScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
