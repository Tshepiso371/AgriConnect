import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MarketService {


  Future<List> getCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('crops');

    if (data == null) return [];

    return jsonDecode(data);
  }


  Future<bool> buyCrop({
    required String buyerEmail,
    required String farmerEmail,
    required String cropName,
    required int quantity,
    required String type, // pickup or delivery
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // GET CROPS
    final cropsString = prefs.getString('crops');
    if (cropsString == null) return false;

    List crops = jsonDecode(cropsString);

    for (var crop in crops) {
      if (crop['name'] == cropName &&
          crop['farmerEmail'] == farmerEmail) {

        if (crop['quantity'] < quantity) {
          return false; // not enough stock
        }


        crop['quantity'] -= quantity;
      }
    }


    await prefs.setString('crops', jsonEncode(crops));


    final ordersString = prefs.getString('orders');
    List orders = ordersString != null ? jsonDecode(ordersString) : [];

    orders.add({
      "buyerEmail": buyerEmail,
      "farmerEmail": farmerEmail,
      "cropName": cropName,
      "quantityBought": quantity,
      "type": type,
    });

    await prefs.setString('orders', jsonEncode(orders));


    final notifString = prefs.getString('notifications');
    List notifs = notifString != null ? jsonDecode(notifString) : [];

    notifs.add({
      "farmerEmail": farmerEmail,
      "message": "$buyerEmail bought $quantity kg of $cropName"
    });

    await prefs.setString('notifications', jsonEncode(notifs));

    return true;
  }


  Future<List> getNotifications(String farmerEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notifications');

    if (data == null) return [];

    List notifs = jsonDecode(data);

    return notifs
        .where((n) => n['farmerEmail'] == farmerEmail)
        .toList();
  }
}