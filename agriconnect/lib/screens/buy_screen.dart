import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../providers/notification_provider.dart';
import '../services/auth_service.dart';
import '../models/crop_model.dart';

class BuyScreen extends StatefulWidget {
  final CropModel crop;

  const BuyScreen({super.key, required this.crop});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  int quantity = 1;
  String type = "pickup";

  void handlePurchase() async {
    final user = await AuthService().getUser();

    if (!mounted) return;
    
    final cropProvider = Provider.of<CropProvider>(context, listen: false);
    final notificationProvider =
    Provider.of<NotificationProvider>(context, listen: false);

    final success = await cropProvider.buyCrop(
      crop: widget.crop,
      quantity: quantity,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough stock")),
      );
      return;
    }

    // Notification for farmer
    if (user != null) {
      notificationProvider.addNotification(
        "${user['name']} bought $quantity of ${widget.crop.name} ($type)",
        widget.crop.farmerEmail ?? "",
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Purchase successful")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buy Crop")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.crop.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("Available: ${widget.crop.quantity}"),

            const SizedBox(height: 20),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter quantity",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                quantity = int.tryParse(value) ?? 1;
              },
            ),

            const SizedBox(height: 20),

            DropdownButton<String>(
              value: type,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "pickup", child: Text("Pickup")),
                DropdownMenuItem(value: "delivery", child: Text("Delivery")),
              ],
              onChanged: (value) {
                setState(() {
                  type = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: handlePurchase,
              child: const Text("Confirm Purchase"),
            ),
          ],
        ),
      ),
    );
  }
}
