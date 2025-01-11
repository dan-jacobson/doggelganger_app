import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CalculatingView extends StatefulWidget {
  const CalculatingView({super.key});

  @override
  CalculatingViewState createState() => CalculatingViewState();
}

class CalculatingViewState extends State<CalculatingView>
    with SingleTickerProviderStateMixin {
  TextStyle get _baseTextStyle => GoogleFonts.quicksand();
  late AnimationController _controller;
  late Animation<double> _iconTransitionAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _iconTransitionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 8 * math.pi)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 8 * math.pi, end: 16 * math.pi)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);
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
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: IconTransition(
                  animation: _iconTransitionAnimation,
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
    super.key,
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final pawOpacity = 1 - progress;
        final handOpacity = progress;

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
