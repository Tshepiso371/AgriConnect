import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../services/auth_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data as Map<String, dynamic>;

        final notifications =
        Provider.of<NotificationProvider>(context)
            .getUserNotifications(user['email']);

        return Scaffold(
          appBar: AppBar(title: const Text("Notifications")),
          body: notifications.isEmpty
              ? const Center(child: Text("No notifications"))
              : ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final note = notifications[index];

              return ListTile(
                title: Text(note.message),
                subtitle: Text(
                  note.date.toString(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}