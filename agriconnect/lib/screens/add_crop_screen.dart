import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/crop_model.dart';
import '../providers/crop_provider.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> takePicture() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Crop")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Crop Name"),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text("Upload Image"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: takePicture,
                  child: const Text("Take Picture"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 120)
                : const Text("No image selected"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final base64Image =
                _imageBytes != null ? base64Encode(_imageBytes!) : null;

                final crop = CropModel(
                  name: nameController.text,
                  quantity: quantityController.text,
                  imageBase64: base64Image,
                );

                await Provider.of<CropProvider>(context, listen: false)
                    .addCrop(crop);

                Navigator.pop(context);
              },
              child: const Text("Save Crop"),
            ),
          ],
        ),
      ),
    );
  }
}