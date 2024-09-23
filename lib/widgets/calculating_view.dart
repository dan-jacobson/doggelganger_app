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
  late Animation<double> _progressAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 4 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
            animation: _controller,
            builder: (context, child) {
              final progress = _progressAnimation.value;
              final rotationSpeed = math.sin(progress * math.pi);
              return Transform.rotate(
                angle: _rotationAnimation.value * rotationSpeed,
                child: IconTransition(
                  animation: _progressAnimation,
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
        final progress = animation.value;
        final pawOpacity = math.cos(progress * math.pi) * 0.5 + 0.5;
        final handOpacity = 1 - pawOpacity;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: pawOpacity,
              child: Icon(
                Icons.pets,
                size: size,
                color: color,
              ),
            ),
            Opacity(
              opacity: handOpacity,
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
