import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  void addNotification(String message, String forUser) {
    _notifications.add(
      NotificationModel(
        message: message,
        date: DateTime.now(),
        forUser: forUser,
      ),
    );

    notifyListeners();
  }

  // :fire: FILTER FOR SPECIFIC USER
  List<NotificationModel> getUserNotifications(String email) {
    return _notifications
        .where((n) => n.forUser == email)
        .toList();
  }
}