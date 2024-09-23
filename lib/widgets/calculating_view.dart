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
                child: CustomPaint(
                  painter: PawHandPrinter(
                    animationValue: _animation.value,
                    color: Theme.of(context).primaryColor,
                  ),
                  size: const Size(100, 100),
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
class PawHandPrinter extends CustomPainter {
  final double animationValue;
  final Color color;

  PawHandPrinter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final pawPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw paw print
    if (animationValue <= 0.5) {
      final pawProgress = 1 - (animationValue * 2);
      _drawPaw(canvas, centerX, centerY, pawPaint, pawProgress);
    }

    // Draw hand print
    if (animationValue >= 0.5) {
      final handProgress = (animationValue - 0.5) * 2;
      _drawHand(canvas, centerX, centerY, pawPaint, handProgress);
    }
  }

  void _drawPaw(Canvas canvas, double centerX, double centerY, Paint paint, double progress) {
    final mainCircleRadius = 20.0 * progress;
    canvas.drawCircle(Offset(centerX, centerY), mainCircleRadius, paint);

    final smallCircleRadius = 10.0 * progress;
    final distance = 30.0 * progress;

    for (var i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2);
      final x = centerX + math.cos(angle) * distance;
      final y = centerY + math.sin(angle) * distance;
      canvas.drawCircle(Offset(x, y), smallCircleRadius, paint);
    }
  }

  void _drawHand(Canvas canvas, double centerX, double centerY, Paint paint, double progress) {
    final palmRadius = 25.0 * progress;
    canvas.drawCircle(Offset(centerX, centerY), palmRadius, paint);

    final fingerLength = 40.0 * progress;
    final fingerWidth = 15.0 * progress;

    for (var i = 0; i < 5; i++) {
      final angle = (i - 2) * (math.pi / 8);
      final startX = centerX + math.cos(angle) * palmRadius;
      final startY = centerY + math.sin(angle) * palmRadius;
      final endX = startX + math.cos(angle) * fingerLength;
      final endY = startY + math.sin(angle) * fingerLength;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = fingerWidth,
      );
      canvas.drawCircle(Offset(endX, endY), fingerWidth / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
