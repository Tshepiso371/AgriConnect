import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/crop_provider.dart';
import '../models/crop_model.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // :camera_with_flash: Function to open camera
  Future<void> pickImage() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Crop"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // :ear_of_rice: Crop Name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Crop Name",
                ),
              ),

              const SizedBox(height: 10),

              // :package: Quantity
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                ),
              ),

              const SizedBox(height: 20),

              // :camera_with_flash: Camera Button
              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Take Picture"),
              ),

              const SizedBox(height: 10),

              // :frame_with_picture: Image Preview
              _image != null
                  ? Image.file(
                _image!,
                height: 120,
              )
                  : const Text("No image selected"),

              const SizedBox(height: 20),

              // :floppy_disk: Save Button
              ElevatedButton(
                onPressed: () {
                  final crop = CropModel(
                    name: nameController.text,
                    quantity: quantityController.text,
                    imagePath: _image?.path,
                  );

                  Provider.of<CropProvider>(context, listen: false)
                      .addCrop(crop);

                  Navigator.pop(context);
                },
                child: const Text("Save Crop"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}