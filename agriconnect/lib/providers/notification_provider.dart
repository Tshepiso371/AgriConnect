import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  static const String _notifKey = 'user_notifications';

  List<NotificationModel> get notifications => _notifications;

  NotificationProvider() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notifString = prefs.getString(_notifKey);
    if (notifString != null) {
      final List<dynamic> decoded = jsonDecode(notifString);
      _notifications = decoded.map((item) => NotificationModel(
        message: item['message'],
        date: DateTime.parse(item['date']),
        forUser: item['forUser'],
      )).toList();
      notifyListeners();
    }
  }

  Future<void> addNotification(String message, String forUser) async {
    final newNotif = NotificationModel(
      message: message,
      date: DateTime.now(),
      forUser: forUser,
    );
    _notifications.add(newNotif);
    
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_notifications.map((n) => {
      'message': n.message,
      'date': n.date.toIso8601String(),
      'forUser': n.forUser,
    }).toList());
    
    await prefs.setString(_notifKey, encoded);
    notifyListeners();
  }

  List<NotificationModel> getUserNotifications(String email) {
    return _notifications.where((n) => n.forUser == email).toList();
  }


  List<NotificationModel> getOrderHistory(String email) {
    return _notifications.where((n) => n.forUser == email && n.message.contains("confirmed")).toList();
  }
}
