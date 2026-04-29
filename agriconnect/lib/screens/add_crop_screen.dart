import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/crop_model.dart';
import '../providers/crop_provider.dart';
import '../services/auth_service.dart';

class AddCropScreen extends StatefulWidget {
  final CropModel? cropToEdit;
  const AddCropScreen({super.key, this.cropToEdit});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.cropToEdit != null) {
      nameController.text = widget.cropToEdit!.name;
      quantityController.text = widget.cropToEdit!.quantity;
      priceController.text = widget.cropToEdit!.price.toString();
      if (widget.cropToEdit!.imageBase64 != null) {
        _imageBytes = base64Decode(widget.cropToEdit!.imageBase64!);
      }
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cropToEdit != null ? "Edit Crop" : "Add Crop")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Crop Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity (kg)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price per kg (\$)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(onPressed: pickImage, icon: const Icon(Icons.image), label: const Text("Gallery")),
                ElevatedButton.icon(onPressed: takePicture, icon: const Icon(Icons.camera_alt), label: const Text("Camera")),
              ],
            ),
            const SizedBox(height: 15),
            _imageBytes != null
                ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_imageBytes!, height: 150, fit: BoxFit.cover))
                : const Text("No image selected"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () async {
                  if (nameController.text.isEmpty || quantityController.text.isEmpty || priceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fill all fields")));
                    return;
                  }

                  final base64Image = _imageBytes != null ? base64Encode(_imageBytes!) : null;
                  final user = await AuthService().getUser();

                  final crop = CropModel(
                    name: nameController.text,
                    quantity: quantityController.text,
                    imageBase64: base64Image,
                    farmerEmail: user!['email'],
                    price: double.tryParse(priceController.text) ?? 0.0,
                    rating: widget.cropToEdit?.rating ?? 4.0,
                  );

                  if (widget.cropToEdit != null) {
                    await Provider.of<CropProvider>(context, listen: false).updateCrop(widget.cropToEdit!, crop);
                  } else {
                    await Provider.of<CropProvider>(context, listen: false).addCrop(crop);
                  }

                  Navigator.pop(context);
                },
                child: Text(widget.cropToEdit != null ? "Update Product" : "Save Product"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
