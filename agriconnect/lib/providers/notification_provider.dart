import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  void addNotification(String message) {
    _notifications.add(
      NotificationModel(
        message: message,
        date: DateTime.now(),
      ),
    );

    notifyListeners();
  }
}