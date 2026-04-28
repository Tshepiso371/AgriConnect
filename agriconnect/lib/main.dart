import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/crop_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/login_screen.dart';
import 'screens/farmer_dashboard.dart';
import 'screens/buyer_dashboard.dart';
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
          primaryColor: Colors.green,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
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

            if (!snapshot.hasData || snapshot.data == null) {
              return const LoginScreen();
            }

            final user = snapshot.data!;
            if (user['role'] == 'farmer') {
              return const FarmerDashboard();
            } else {
              return const BuyerDashboard();
            }
          },
        ),

        routes: {
          '/farmer': (context) => const FarmerDashboard(),
          '/buyer': (context) => const BuyerDashboard(),
          '/signup': (context) => const SignUpScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
