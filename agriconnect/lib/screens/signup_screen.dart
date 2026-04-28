import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "farmer";
  final authService = AuthService();

  void handleSignUp() async {
    await authService.signUp(
      nameController.text,
      emailController.text,
      passwordController.text,
      role,
    );

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password")),

            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: "farmer", child: Text("Farmer")),
                DropdownMenuItem(value: "buyer", child: Text("Buyer")),
              ],
              onChanged: (value) => setState(() => role = value!),
            ),

            ElevatedButton(
              onPressed: handleSignUp,
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}