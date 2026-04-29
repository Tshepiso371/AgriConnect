import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import 'buy_screen.dart';
import 'location_screen.dart';
import 'order_history_screen.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? weatherData;
  bool isWeatherLoading = true;
  String searchQuery = "";
  String filterValue = "All crops";

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadWeather();
  }

  void _loadData() async {
    final user = await AuthService().getUser();
    setState(() => currentUser = user);
    if (mounted) {
      Provider.of<CropProvider>(context, listen: false).loadCrops();
    }
  }

  Future<void> _loadWeather() async {
    final data = await WeatherService().getWeather("Durban");
    if (mounted) {
      setState(() {
        weatherData = data;
        isWeatherLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final crops = Provider.of<CropProvider>(context).crops;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    var filteredCrops = crops.where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    
    // Fake Filter Logic
    if (filterValue == "Recently added") {
      filteredCrops = filteredCrops.reversed.toList();
    } else if (filterValue == "Nearby crops") {
       filteredCrops.shuffle();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Marketplace"),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
          ),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => _showCart()),
              if (cart.itemCount > 0)
                Positioned(
                  right: 5, 
                  top: 5, 
                  child: CircleAvatar(
                    radius: 8, 
                    backgroundColor: Colors.red, 
                    child: Text(
                      cart.itemCount.toString(), 
                      style: const TextStyle(fontSize: 10, color: Colors.white)
                    )
                  )
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await AuthService().logout();
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
      body: Column(
        children: [
          _buildWeatherHeader(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search crops...", 
                      prefixIcon: const Icon(Icons.search), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: filterValue,
                  items: ["All crops", "Nearby crops", "Recently added"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                      .toList(),
                  onChanged: (val) => setState(() => filterValue = val!),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredCrops.isEmpty
                ? const Center(child: Text("No products found."))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 0.65, 
                      crossAxisSpacing: 10, 
                      mainAxisSpacing: 10
                    ),
                    itemCount: filteredCrops.length,
                    itemBuilder: (context, index) {
                      final crop = filteredCrops[index];
                      bool isOutOfStock = crop.isSold || (int.tryParse(crop.quantity) ?? 0) <= 0;
                      
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    child: crop.imageBase64 != null
                                        ? Image.memory(base64Decode(crop.imageBase64!), width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                                        : Container(width: double.infinity, color: Colors.green.shade100, child: const Center(child: Icon(Icons.eco, size: 50))),
                                  ),
                                  if (isOutOfStock)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                      ),
                                      child: const Center(child: Text("SOLD OUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text("R${crop.price}/kg", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      ...List.generate(5, (i) => Icon(Icons.star, color: i < crop.rating.floor() ? Colors.amber : Colors.grey, size: 12)),
                                      const SizedBox(width: 4),
                                      Text(crop.rating.toString(), style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                  const Text("Trusted Farmer", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero, 
                                        backgroundColor: Colors.green, 
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                      ),
                                      onPressed: isOutOfStock ? null : () {
                                        cart.addItem(crop);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${crop.name} added to cart"), duration: const Duration(seconds: 1)));
                                      },
                                      child: const Text("Add to Cart", style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCart() {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CartScreen()));
  }

  Widget _buildWeatherHeader() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400]), 
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Hello, ${currentUser?['name'] ?? 'Buyer'}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (!isWeatherLoading && weatherData != null)
              Text("${weatherData!['main']['temp']}°C - ${weatherData!['weather'][0]['description']}", style: const TextStyle(color: Colors.white)),
          ]),
          const Icon(Icons.cloud, color: Colors.white, size: 40),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text("Cart is empty"))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items.values.toList()[i];
                      final key = cart.items.keys.toList()[i];
                      return ListTile(
                        leading: item.crop.imageBase64 != null 
                            ? Image.memory(base64Decode(item.crop.imageBase64!), width: 40, height: 40, fit: BoxFit.cover)
                            : const Icon(Icons.eco),
                        title: Text(item.crop.name),
                        subtitle: Text("R${item.crop.price} x ${item.quantity}"),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => cart.removeItem(key)),
                      );
                    },
                  ),
          ),
          if (cart.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("R${cart.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const DeliveryOptionScreen())),
                      child: const Text("Proceed to Checkout"),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}

class DeliveryOptionScreen extends StatefulWidget {
  const DeliveryOptionScreen({super.key});

  @override
  State<DeliveryOptionScreen> createState() => _DeliveryOptionScreenState();
}

class _DeliveryOptionScreenState extends State<DeliveryOptionScreen> {
  String method = "Delivery";
  final addressController = TextEditingController();
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await AuthService().getUser();
    if (mounted) {
      setState(() => currentUser = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose Delivery Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              title: const Text("Delivery"), 
              subtitle: const Text("To your doorstep"),
              leading: Radio(value: "Delivery", groupValue: method, onChanged: (v) => setState(() => method = v!))
            ),
            ListTile(
              title: const Text("Pickup"), 
              subtitle: const Text("Collect from farm"),
              leading: Radio(value: "Pickup", groupValue: method, onChanged: (v) => setState(() => method = v!))
            ),
            const Divider(),
            if (method == "Delivery") ...[
              const Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: addressController, 
                decoration: const InputDecoration(hintText: "Enter your address", border: OutlineInputBorder())
              ),
              const SizedBox(height: 10),
              const Text("Estimated arrival: 2 working days", style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic)),
            ],
            if (method == "Pickup") ...[
              Card(
                color: Colors.green.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(15), 
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(child: Text("Pickup Location: Farm HQ (2.5km away)", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  )
                )
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () async {
                   if (method == "Delivery" && addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter address")));
                      return;
                   }

                   final cart = Provider.of<CartProvider>(context, listen: false);
                   final notifications = Provider.of<NotificationProvider>(context, listen: false);
                   final cropProvider = Provider.of<CropProvider>(context, listen: false);
                   
                   String itemDetails = cart.items.values.map((item) => "${item.quantity}kg of ${item.crop.name}").join(", ");
                   String buyerMsg = "Order confirmed! Total: R${cart.totalAmount.toStringAsFixed(2)}. Items: $itemDetails. ";
                   
                   if (method == "Delivery") {
                      buyerMsg += "Will be delivered within 2 working days.";
                   } else {
                      buyerMsg += "Please collect from Farm HQ.";
                   }
                   
                   // Notify Buyer
                   await notifications.addNotification(buyerMsg, currentUser?['email'] ?? "buyer");

                   // Notify Farmers and Update Stock
                   for (var item in cart.items.values) {
                     // Notify Farmer
                     await notifications.addNotification(
                       "${currentUser?['name'] ?? 'A buyer'} purchased ${item.quantity}kg of ${item.crop.name}. Delivery method: $method.", 
                       item.crop.farmerEmail ?? ""
                     );
                     
                     // Update Stock in Provider/DB
                     await cropProvider.buyCrop(crop: item.crop, quantity: item.quantity);
                   }
                   
                   cart.clear();
                   if (mounted) {
                     showDialog(
                       context: context,
                       builder: (ctx) => AlertDialog(
                         title: const Text("Order Placed!"),
                         content: Text(buyerMsg),
                         actions: [
                           TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text("OK"))
                         ],
                       )
                     );
                   }
                },
                child: const Text("Confirm Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
