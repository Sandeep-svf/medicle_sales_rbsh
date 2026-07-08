import 'dart:math';

import 'package:flutter/material.dart';

class BeatAreaAvatar extends StatelessWidget {
  final List<Color> colors;
  final int doctorCount;
  final double radius;

  const BeatAreaAvatar({
    super.key,
    required this.colors,
    required this.doctorCount,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CustomPaint(
        painter: _BeatPainter(colors),
        child: Center(
          child: Text(
            doctorCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _BeatPainter extends CustomPainter {
  final List<Color> colors;

  _BeatPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final center = rect.center;

    final radius = size.width / 2;

    if (colors.isEmpty) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = Colors.grey,
      );
    } else if (colors.length == 1) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = colors.first,
      );
    } else {
      final sweep = (2 * pi) / colors.length;

      double start = -pi / 2;

      for (final color in colors) {
        canvas.drawArc(
          rect,
          start,
          sweep,
          true,
          Paint()..color = color,
        );

        start += sweep;
      }
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}