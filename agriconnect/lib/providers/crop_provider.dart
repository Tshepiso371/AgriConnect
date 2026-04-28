import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop_model.dart';


class CropProvider extends ChangeNotifier {

  double? latitude;
  double? longitude;

  List<CropModel> _crops = [];

  List<CropModel> get crops => _crops;

  // Load crops from storage
  Future<void> loadCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('crops');

    if (data != null) {
      final List decoded = jsonDecode(data);
      _crops = decoded.map((e) => CropModel.fromJson(e)).toList();
    }

    notifyListeners();
  }

  // Save crops
  Future<void> saveCrops() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _crops.map((e) => e.toJson()).toList(),
    );

    await prefs.setString('crops', encoded);
  }

  // Add crop
  Future<void> addCrop(CropModel crop) async {
    _crops.add(crop);
    await saveCrops();
    notifyListeners();
  }

  void setLocation(double lat, double lng) {
    latitude = lat;
    longitude = lng;
    notifyListeners();
  }
  }
