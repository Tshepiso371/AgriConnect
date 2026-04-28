import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/crop_provider.dart';
import '../providers/notification_provider.dart';
import 'weather_screen.dart';
import 'location_screen.dart';
import 'buy_screen.dart';
import 'add_crop_screen.dart';
import '../services/auth_service.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  Map<String, dynamic>? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authService = AuthService();
    final user = await authService.getUser();
    
    if (mounted) {
      setState(() {
        currentUser = user;
        isLoading = false;
      });
    }

    // Refresh crops from DB
    Provider.of<CropProvider>(context, listen: false).loadCrops();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final crops = Provider.of<CropProvider>(context).crops;
    final isFarmer = currentUser?['role'] == 'farmer';

    return Scaffold(
      appBar: AppBar(
        title: Text(isFarmer ? "My Farm Products" : "Available Crops"),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserHeader(),
          Expanded(
            child: crops.isEmpty
                ? const Center(child: Text("No crops found. Tap + to add some!"))
                : ListView.builder(
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final crop = crops[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: crop.imageBase64 != null
                              ? Image.memory(base64Decode(crop.imageBase64!), width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.eco, color: Colors.green),
                          title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Quantity: ${crop.quantity}"),
                          trailing: !isFarmer
                              ? ElevatedButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BuyScreen(crop: crop))),
                                  child: const Text("Buy"),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Logic to delete if needed
                                  },
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isFarmer
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCropScreen()));
                // Refresh list after returning
                Provider.of<CropProvider>(context, listen: false).loadCrops();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      color: Colors.green.shade50,
      child: Column(
        children: [
          Text("Welcome, ${currentUser?['name'] ?? 'User'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Role: ${currentUser?['role']?.toUpperCase()}", style: TextStyle(color: Colors.green.shade700)),
        ],
      ),
    );
  }

  void _showNotifications() {
    final notifications = Provider.of<NotificationProvider>(context, listen: false).notifications;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Notifications"),
        content: notifications.isEmpty 
          ? const Text("No new notifications")
          : Column(mainAxisSize: MainAxisSize.min, children: notifications.map((n) => ListTile(title: Text(n.message))).toList()),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }
}
