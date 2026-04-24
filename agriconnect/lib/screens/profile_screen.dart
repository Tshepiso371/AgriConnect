import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  String role = 'farmer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),

            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
              ],
              onChanged: (value) {
                setState(() {
                  role = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final user = UserModel(
                  name: nameController.text,
                  role: role,
                );

                Provider.of<UserProvider>(context, listen: false)
                    .setUser(user);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile Saved')),
                );
              },
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}