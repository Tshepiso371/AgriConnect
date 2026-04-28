import 'package:flutter/material.dart';
import '../services/weather_service.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    final data = await weatherService.getWeather("Durban");

    setState(() {
      weatherData = data;
    });
  }

  // :white_check_mark: CORRECT PLACE FOR FUNCTION
  String getAdvice(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains("rain")) {
      return "Good time to plant crops :seedling:";
    } else if (condition.contains("clear")) {
      return "Perfect for harvesting :sunny:";
    } else if (condition.contains("cloud")) {
      return "Monitor crops :barely_sunny:";
    } else {
      return "Check conditions :warning:";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather")),
      body: Center(
        child: weatherData == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${weatherData!['main']['temp']}°C",
              style: const TextStyle(fontSize: 40),
            ),
            Text(weatherData!['weather'][0]['description']),
            const SizedBox(height: 10),
            Text(
              getAdvice(weatherData!['weather'][0]['description']),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}