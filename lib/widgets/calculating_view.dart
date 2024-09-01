import 'package:flutter/material.dart';

class CalculatingView extends StatefulWidget {
  const CalculatingView({super.key});

  @override
  _CalculatingViewState createState() => _CalculatingViewState();
}

class _CalculatingViewState extends State<CalculatingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: Icon(
              Icons.pets,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Finding your doggelganger...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This may take a moment',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
