import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/weather_screen.dart';
import 'location_screen.dart';
import '../providers/crop_provider.dart';
import 'add_crop_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Crops"),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeatherScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: crops.isEmpty
          ? const Center(child: Text("No crops yet"))
          : ListView.builder(
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];

          return ListTile(
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
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddCropScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  }
