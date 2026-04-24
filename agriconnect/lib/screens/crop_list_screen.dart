import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import 'add_crop_screen.dart';
import 'dart:io';

class CropListScreen extends StatelessWidget {
  const CropListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final crops = Provider.of<CropProvider>(context).crops;

    return Scaffold(
      appBar: AppBar(title: const Text("My Crops")),
      body: ListView.builder(
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];

          return ListTile(
            leading: crop.imagePath != null
                ? Image.file(
              File(crop.imagePath!),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : const Icon(Icons.image),

            title: Text(crop.name),
            subtitle: Text(crop.quantity),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddCropScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}