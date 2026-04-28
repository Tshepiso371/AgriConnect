class CropModel {
  final String name;
  final String quantity;
  final String? imageBase64;
  final String? farmerEmail;
  final double? latitude;
  final double? longitude;

  CropModel({
    required this.name,
    required this.quantity,
    this.imageBase64,
    required this.farmerEmail,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'imageBase64': imageBase64,
      'farmerEmail': farmerEmail,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      name: json['name'],
      quantity: json['quantity'],
      imageBase64: json['imageBase64'],
      farmerEmail: json['farmerEmail'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
