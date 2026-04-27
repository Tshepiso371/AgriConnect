import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService locationService = LocationService();
  Position? position;
  String error = "";

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    try {
      final pos = await locationService.getCurrentLocation();

      setState(() {
        position = pos;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Location")),
      body: Center(
        child: position != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Latitude: ${position!.latitude}"),
            Text("Longitude: ${position!.longitude}"),
          ],
        )
            : error.isNotEmpty
            ? Text(error)
            : const CircularProgressIndicator(),
      ),
    );
  }
}