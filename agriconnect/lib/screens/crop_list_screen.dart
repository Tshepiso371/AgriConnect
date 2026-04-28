import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/crop_provider.dart';
import '../providers/notification_provider.dart';
import 'add_crop_screen.dart';
import 'weather_screen.dart';
import 'location_screen.dart';
import '../services/auth_service.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CropProvider>(context, listen: false).loadCrops();
    });
  }

  @override
  Widget build(BuildContext context) {
    final crops = Provider.of<CropProvider>(context).crops;
    final route = ModalRoute.of(context)?.settings.name;
    final isFarmer = route == '/farmer';

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Crops"),
        actions: [
          // WEATHER
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeatherScreen()),
              );
            },
          ),

          // LOCATION
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationScreen()),
              );
            },
          ),

          // NOTIFICATIONS
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              final notifications = Provider.of<NotificationProvider>(
                context,
                listen: false,
              ).notifications;



              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Notifications"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: notifications
                        .map((n) => Text(n))
                        .toList(),
                  ),
                ),
              );
            },
          ),

          // LOGOUT
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: AuthService().getUser(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Loading...");
                }

                final user = snapshot.data as Map<String, dynamic>;

                return Column(
                  children: [
                    Text(
                      "Welcome ${user['name']} :wave:",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isFarmer
                          ? "Logged in as Farmer :male-farmer:"
                          : "Logged in as Buyer :shopping_trolley:",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: crops.isEmpty
                ? const Center(child: Text("No crops yet"))
                : ListView.builder(
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: crop.imageBase64 != null
                        ? Image.memory(
                      base64Decode(crop.imageBase64!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image),

                    title: Text(crop.name),
                    subtitle: Text(crop.quantity),

                    // BUY BUTTON (only for buyer)
                    trailing: !isFarmer
                        ? ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title:
                            const Text("Choose option"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Provider.of<
                                      NotificationProvider>(
                                      context,
                                      listen: false)
                                      .addNotification(
                                      "New order: ${crop.name} (Delivery)");

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Delivery selected")),
                                  );
                                },
                                child:
                                const Text("Delivery"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Provider.of<
                                      NotificationProvider>(
                                      context,
                                      listen: false)
                                      .addNotification(
                                      "New order: ${crop.name} (Pickup)");

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Pickup selected")),
                                  );
                                },
                                child:
                                const Text("Pickup"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("Buy"),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ADD BUTTON (only farmer)
      floatingActionButton: isFarmer
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddCropScreen()),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}