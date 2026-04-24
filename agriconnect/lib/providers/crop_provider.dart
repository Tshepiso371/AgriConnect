import 'package:flutter/material.dart';
import '../models/crop_model.dart';

class CropProvider extends ChangeNotifier {
  final List<CropModel> _crops = [];

  List<CropModel> get crops => _crops;

  void addCrop(CropModel crop) {
    _crops.add(crop);
    notifyListeners();
  }
}