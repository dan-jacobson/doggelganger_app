import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class BottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const BottomButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: AutoSizeText(
        label,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        minFontSize: 14,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: Size(MediaQuery.of(context).size.width * .65, 60),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
    );
  }
}
