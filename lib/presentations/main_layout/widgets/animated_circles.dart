import 'dart:math' as math;

import 'package:flutter/material.dart';

class CirclesPainter extends CustomPainter {
  final double animationValue;
  final List<AnimatedCircle> circles = [];
  final math.Random random = math.Random(42);

  CirclesPainter(this.animationValue) {
    _generateCircles();
  }

  void _generateCircles() {
    circles.clear();

    for (int i = 0; i < 10; i++) {
      circles.add(
        AnimatedCircle(
          radius: 15 + random.nextDouble() * 20,
          startY: random.nextDouble() * 130,
          speed: 0.2 + random.nextDouble() * 0.3,
          opacity: 0.08 + random.nextDouble() * 0.12,
          verticalOffset: (random.nextDouble() - 0.5) * 0.1,
          delay: random.nextDouble(),
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var circle in circles) {
      double progress = ((animationValue + circle.delay) % 1.0);

      double currentX =
          -circle.radius + (progress * (size.width + circle.radius * 2));

      double currentY =
          circle.startY +
          (math.sin(progress * 4 * math.pi) * circle.verticalOffset * 20);

      currentY = currentY.clamp(circle.radius, size.height - circle.radius);

      final paint = Paint()
        ..color = Colors.white.withOpacity(circle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(currentX, currentY), circle.radius, paint);

      final ringPaint = Paint()
        ..color = Colors.white.withOpacity(circle.opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawCircle(
        Offset(currentX, currentY),
        circle.radius + 3,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedCircle {
  final double radius;
  final double startY;
  final double speed;
  final double opacity;
  final double verticalOffset;
  final double delay;

  AnimatedCircle({
    required this.radius,
    required this.startY,
    required this.speed,
    required this.opacity,
    required this.verticalOffset,
    required this.delay,
  });
}
