# AgriConnect 🚜

AgriConnect is a comprehensive cross-platform Flutter application designed to bridge the gap between farmers and buyers. It provides a direct digital marketplace for fresh produce, featuring real-time weather integration, distance-based pickup options, and a secure user experience tailored to both farming and buying needs.

---

##  Key Features

### For Farmers 🌾
- **Inventory Management**: Add, edit, and delete crops with images, quantities, and prices.
- **Integrated Weather Advice**: Real-time weather dashboard with specific farming tips (e.g., planting or harvesting advice).
- **Sales Notifications**: Real-time alerts when a buyer purchases your products.
- **Stock Tracking**: Automatic "SOLD OUT" status when quantity reaches zero.

### For Buyers 🛒

- **Search & Filter**: Find specific crops quickly or filter by "Recently Added" or "Nearby".
- **Shopping Cart**: Add multiple items to a cart and see a live total.
- **Secure Checkout**: Choose between **Delivery** (2-day arrival) or **Pickup** (shows distance to farm).
- **Order History**: Track all your past purchases with real-time data.
- **Trusted Ratings**: View farmer ratings to shop with confidence.

### Global Features 🌍
- **Persistent Profiles**: Login once and stay logged in.
- **Dark Mode**: Seamlessly switch between light and dark themes.
- **Offline Storage**: Uses `SharedPreferences` to ensure your data is safe and accessible without a complex database setup.

---

##  Project Structure & Files

### **Core**
- `lib/main.dart`: Entry point. Manages app initialization, state providers, and global theme routing.

### **Models**
- `crop_model.dart`: Structure for crop data (Price, Rating, Location, etc.).
- `notification_model.dart`: Structure for alerts and order confirmations.

### **Providers (State Management)**
- `crop_provider.dart`: Business logic for managing crops and stock levels.
- `cart_provider.dart`: Manages the shopping cart and checkout totals.
- `notification_provider.dart`: Handles persistent storage of alerts and purchase history.
- `theme_provider.dart`: Manages global Dark/Light mode state.

### **Screens**
- `farmer_dashboard.dart`: Farmer-specific UI with inventory and weather advice.
- `buyer_dashboard.dart`: Marketplace UI with search, grid view, and checkout.
- `login_screen.dart` / `signup_screen.dart`: Beautiful green-themed authentication.
- `add_crop_screen.dart`: Form for uploading produce details and photos.
- `order_history_screen.dart`: Detailed list of a user's previous purchases.

### **Services**
- `auth_service.dart`: Handles secure user sessions and account persistence.
- `database_helper.dart`: Manages local data storage using `SharedPreferences`.
- `weather_service.dart`: Connects to real-time APIs for location-based weather data.

---

##  Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- An IDE (VS Code, Android Studio, etc.)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Tshepiso371/AgriConnect/tree/main/agriconnect
   ```
2. Navigate to the project folder:
   ```bash
   cd agriconnect
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---

##  UI & Design
The app features a **modern green-themed UI** designed to reflect agriculture and nature. It uses Material 3 components, large imagery, and intuitive navigation cards to provide a premium user experience.

---

##  Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Storage**: SharedPreferences (Persistent JSON)
- **API**: Weather API integration
- **Platform Support**: Android, iOS, Web, Windows

---

Developed by Tshepiso Mohlabane
