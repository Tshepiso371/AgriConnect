import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../services/database_helper.dart';

class CropProvider with ChangeNotifier {
  List<CropModel> _crops = [];
  double? _latitude;
  double? _longitude;

  List<CropModel> get crops => _crops;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  Future<void> loadCrops() async {
    try {
      _crops = await DatabaseHelper.instance.getCrops();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading crops: $e");
    }
  }

  Future<void> addCrop(CropModel crop) async {
    try {
      await DatabaseHelper.instance.insertCrop(crop);
      await loadCrops();
    } catch (e) {
      debugPrint("Error adding crop: $e");
    }
  }

  Future<void> updateCrop(CropModel oldCrop, CropModel newCrop) async {
    try {
      await DatabaseHelper.instance.deleteCrop(oldCrop.name, oldCrop.farmerEmail);
      await DatabaseHelper.instance.insertCrop(newCrop);
      await loadCrops();
    } catch (e) {
      debugPrint("Error updating crop: $e");
    }
  }

  Future<void> deleteCrop(CropModel crop) async {
    try {
      await DatabaseHelper.instance.deleteCrop(crop.name, crop.farmerEmail);
      await loadCrops();
    } catch (e) {
      debugPrint("Error deleting crop: $e");
    }
  }

  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  Future<bool> buyCrop({required CropModel crop, required int quantity}) async {
    try {
      int currentQty = int.tryParse(crop.quantity) ?? 0;
      if (currentQty < quantity) return false;

      int remainingQty = currentQty - quantity;
      
      await DatabaseHelper.instance.deleteCrop(crop.name, crop.farmerEmail);
      
      if (remainingQty > 0) {
        await DatabaseHelper.instance.insertCrop(CropModel(
          name: crop.name,
          quantity: remainingQty.toString(),
          imageBase64: crop.imageBase64,
          farmerEmail: crop.farmerEmail,
          latitude: crop.latitude,
          longitude: crop.longitude,
        ));
      }

      await loadCrops();
      return true;
    } catch (e) {
      debugPrint("Error buying crop: $e");
      return false;
    }
  }
}
