import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerButton extends StatelessWidget {
  final Function(XFile) onImageSelected;

  const ImagePickerButton(
      {super.key, required this.onImageSelected, required IconData icon});

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
      icon: Icons.pets,
        onPressed: _pickImage,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
    )
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets),
            Text(
              'Find your doggelganger!',
              style: TextStyle(fontSize: 18),
            ),
            Icon(Icons.pets),
          ],
        ),
      );
  }
}
