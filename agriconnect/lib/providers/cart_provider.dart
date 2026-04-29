import 'package:flutter/material.dart';
import '../models/crop_model.dart';

class CartItem {
  final CropModel crop;
  int quantity;

  CartItem({required this.crop, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.crop.price * cartItem.quantity;
    });
    return total;
  }

  int get itemCount => _items.length;

  void addItem(CropModel crop) {
    if (_items.containsKey(crop.name + (crop.farmerEmail ?? ""))) {
      _items.update(
        crop.name + (crop.farmerEmail ?? ""),
        (existing) => CartItem(crop: existing.crop, quantity: existing.quantity + 1),
      );
    } else {
      _items.putIfAbsent(
        crop.name + (crop.farmerEmail ?? ""),
        () => CartItem(crop: crop),
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
