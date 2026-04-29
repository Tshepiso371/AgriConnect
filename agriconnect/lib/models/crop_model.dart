class CropModel {
  final String name;
  final String quantity;
  final String? imageBase64;
  final String? farmerEmail;
  final double? latitude;
  final double? longitude;
  final double price;
  final double rating;
  final bool isSold;

  CropModel({
    required this.name,
    required this.quantity,
    this.imageBase64,
    required this.farmerEmail,
    this.latitude,
    this.longitude,
    this.price = 0.0,
    this.rating = 4.0,
    this.isSold = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'imageBase64': imageBase64,
      'farmerEmail': farmerEmail,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'rating': rating,
      'isSold': isSold,
    };
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      name: json['name'],
      quantity: json['quantity'],
      imageBase64: json['imageBase64'],
      farmerEmail: json['farmerEmail'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      isSold: json['isSold'] ?? false,
    );
  }
}
