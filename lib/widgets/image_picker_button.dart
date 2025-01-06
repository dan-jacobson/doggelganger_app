import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerButton extends StatelessWidget {
  final Function(XFile) onImageSelected;

  const ImagePickerButton({super.key, required this.onImageSelected});

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImageSelected(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _pickImage,
      icon: const Icon(Icons.pets, size: 28),
      label: const Text(
        'Find your doggelganger!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        minimumSize: const Size(300, 60),
      ),
    );
  }
}
