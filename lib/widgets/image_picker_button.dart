import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doggelganger_app/widgets/bottom_button.dart';

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
    return BottomButton(
      onPressed: _pickImage,
      icon: Icons.pets,
      label: 'Find your doggelganger match!',
    );
  }
}
