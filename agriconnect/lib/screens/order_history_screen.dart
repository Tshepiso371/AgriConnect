import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../services/auth_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await AuthService().getUser();
    setState(() => currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final history = Provider.of<NotificationProvider>(context).getOrderHistory(currentUser!['email']);

    return Scaffold(
      appBar: AppBar(title: const Text("My Order History")),
      body: history.isEmpty
          ? const Center(child: Text("You haven't placed any orders yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: history.length,
              itemBuilder: (ctx, i) {
                final order = history[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.green),
                    title: Text(order.message.replaceAll("Order confirmed! ", "")),
                    subtitle: Text("${order.date.toString().substring(0, 16)}"),
                    trailing: const Text("Confirmed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                );
              },
            ),
    );
  }
}
