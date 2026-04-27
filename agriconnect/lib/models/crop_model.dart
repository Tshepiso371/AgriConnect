class CropModel {
  final String name;
  final String quantity;
  final String? imageBase64;

  CropModel({
    required this.name,
    required this.quantity,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'imageBase64': imageBase64,
    };
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      name: json['name'],
      quantity: json['quantity'],
      imageBase64: json['imageBase64'],
    );
  }
}