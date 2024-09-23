import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CalculatingView extends StatefulWidget {
  const CalculatingView({super.key});

  @override
  _CalculatingViewState createState() => _CalculatingViewState();
}

class _CalculatingViewState extends State<CalculatingView> with SingleTickerProviderStateMixin {
  TextStyle get _baseTextStyle => GoogleFonts.quicksand();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
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
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 2 * math.pi,
                child: IconTransition(
                  animation: _animation,
                  color: Theme.of(context).primaryColor,
                  size: 100,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Finding your doggelganger...',
            style: _baseTextStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This may take a moment',
            style: _baseTextStyle.copyWith(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class IconTransition extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const IconTransition({
    Key? key,
    required this.animation,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final pawProgress = (1 - (animation.value * 2)).abs();
        final handProgress = ((animation.value - 0.5) * 2).abs();
        
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: pawProgress,
              child: Icon(
                Icons.pets,
                size: size,
                color: color,
              ),
            ),
            Opacity(
              opacity: handProgress,
              child: Icon(
                Icons.pan_tool,
                size: size,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }
}
