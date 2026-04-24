import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications =
        Provider.of<NotificationProvider>(context).notifications;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final note = notifications[index];

          return ListTile(
            title: Text(note.message),
            subtitle: Text(note.date.toString()),
          );
        },
      ),
    );
  }
}