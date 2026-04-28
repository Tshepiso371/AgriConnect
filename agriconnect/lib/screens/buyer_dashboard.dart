import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import 'buy_screen.dart';
import 'location_screen.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
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

  @override
  Widget build(BuildContext context) {
    final crops = Provider.of<CropProvider>(context).crops;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        title: const Text("Buyer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationScreen())),
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
            child: Text("Available Marketplace", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          Expanded(
            child: crops.isEmpty
                ? const Center(child: Text("No crops available yet."))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 20),
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
                                  height: 250, // Much bigger image
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                ),
                                child: const Icon(Icons.image, size: 100, color: Colors.green),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(crop.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                      Text("Qty: ${crop.quantity}", style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text("Farmer: ${crop.farmerEmail}", style: TextStyle(color: Colors.grey.shade600)),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BuyScreen(crop: crop))),
                                      child: const Text("PURCHASE NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
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
    );
  }

  Widget _buildWeatherHeader() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome to AgriConnect, ${currentUser?['name'] ?? 'Buyer'}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (isWeatherLoading)
                const Text("Fetching local weather...", style: TextStyle(color: Colors.white70))
              else if (weatherData != null)
                Text("${weatherData!['main']['temp']}°C in ${weatherData!['name']} - ${weatherData!['weather'][0]['description']}", 
                     style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const Icon(Icons.cloud_queue, size: 40, color: Colors.white),
        ],
      ),
    );
  }
}
