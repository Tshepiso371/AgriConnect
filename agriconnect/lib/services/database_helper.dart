import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const String _cropKey = 'saved_crops';

  // SAVE CROP
  Future<int> insertCrop(CropModel crop) async {
    final prefs = await SharedPreferences.getInstance();
    List<CropModel> currentCrops = await getCrops();
    
    currentCrops.add(crop);
    
    List<String> jsonList = currentCrops.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_cropKey, jsonList);
    
    return 1; // Success
  }

  // GET ALL CROPS
  Future<List<CropModel>> getCrops() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_cropKey);
    
    if (jsonList == null) return [];

    return jsonList.map((item) => CropModel.fromJson(jsonDecode(item))).toList();
  }

  // DELETE CROP
  Future<int> deleteCrop(String name, String? farmerEmail) async {
    final prefs = await SharedPreferences.getInstance();
    List<CropModel> currentCrops = await getCrops();
    
    currentCrops.removeWhere((c) => c.name == name && c.farmerEmail == farmerEmail);
    
    List<String> jsonList = currentCrops.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_cropKey, jsonList);
    
    return 1; // Success
  }
}
