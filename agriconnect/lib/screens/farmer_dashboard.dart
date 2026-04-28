import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../providers/notification_provider.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import 'add_crop_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? weatherData;
  bool isWeatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadWeather();
  }

  void _loadData() async {
    final user = await AuthService().getUser();
    setState(() => currentUser = user);
    if (mounted) {
      Provider.of<CropProvider>(context, listen: false).loadCrops();
    }
  }

  Future<void> _loadWeather() async {
    final data = await WeatherService().getWeather("Durban");
    if (mounted) {
      setState(() {
        weatherData = data;
        isWeatherLoading = false;
      });
    }
  }

  String getAdvice(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("rain")) return "Good time to plant crops 🌱";
    if (condition.contains("clear")) return "Perfect for harvesting ☀️";
    if (condition.contains("cloud")) return "Monitor crops 🌤️";
    return "Check conditions ⚠️";
  }

  @override
  Widget build(BuildContext context) {
    final allCrops = Provider.of<CropProvider>(context).crops;
    final myCrops = allCrops.where((c) => c.farmerEmail == currentUser?['email']).toList();
    final notifications = Provider.of<NotificationProvider>(context).getUserNotifications(currentUser?['email'] ?? "");

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        title: const Text("Farmer Dashboard"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotifications(notifications),
              ),
              if (notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(notifications.length.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeatherHeader(),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text("My Inventory", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          Expanded(
            child: myCrops.isEmpty
                ? const Center(child: Text("No crops yet. Start adding!"))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: myCrops.length,
                    itemBuilder: (context, index) {
                      final crop = myCrops[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (crop.imageBase64 != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.memory(
                                  base64Decode(crop.imageBase64!),
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                ),
                                child: const Icon(Icons.eco, size: 80, color: Colors.green),
                              ),
                            ListTile(
                              title: Text(crop.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              subtitle: Text("Available Quantity: ${crop.quantity}", style: const TextStyle(fontSize: 16)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editCrop(crop)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(crop)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCropScreen()));
          Provider.of<CropProvider>(context, listen: false).loadCrops();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeatherHeader() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, ${currentUser?['name'] ?? 'Farmer'}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              if (isWeatherLoading)
                const Text("Loading weather...", style: TextStyle(color: Colors.white70))
              else if (weatherData != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${weatherData!['main']['temp']}°C - ${weatherData!['weather'][0]['description']}", style: const TextStyle(color: Colors.white, fontSize: 16)),
                    Text(getAdvice(weatherData!['weather'][0]['description']), style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const Icon(Icons.wb_sunny, size: 50, color: Colors.white),
        ],
      ),
    );
  }

  void _showNotifications(List notifications) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Sales Notifications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text("No sales yet."))
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: const Icon(Icons.shopping_basket, color: Colors.green),
                        title: Text(notifications[index].message),
                        subtitle: Text(notifications[index].date.toString().substring(0, 16)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _editCrop(dynamic crop) {
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Edit feature coming soon!")));
  }

  void _confirmDelete(dynamic crop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Crop?"),
        content: Text("Remove ${crop.name} from inventory?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Provider.of<CropProvider>(context, listen: false).deleteCrop(crop);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
