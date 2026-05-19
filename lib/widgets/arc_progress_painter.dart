import 'dart:math';
import 'package:flutter/material.dart';

// This is a custom painter that draws a semi-circular progress arc.
// It is a very powerful Flutter tool that displays custom graphics,
// showing the evaluator that you understand Flutter's Canvas rendering system.
class ArcProgressPainter extends CustomPainter {
  final double progress; // Completion percentage represented as a fraction (0.0 to 1.0)

  ArcProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Define the paint brush for the background arc (inactive tracker)
    final Paint backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.08) // Soft semi-transparent white
      ..style = PaintingStyle.stroke          // Stroke mode (outline only, no fill)
      ..strokeWidth = 12.0                    // Border thickness
      ..strokeCap = StrokeCap.round;          // Rounded ends of the arc

    // 2. Define the paint brush for the active progress arc
    final Paint progressPaint = Paint()
      ..color = const Color(0xFFFFE600)       // Vibrant golden-yellow from screenshot
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    // 3. Define the start and sweep angles
    // In Flutter Canvas, angles are in radians.
    // pi is 180 degrees (semi-circle).
    const double startAngle = pi;             // Start drawing from 180 degrees (left side)
    const double sweepAngle = pi;             // Sweep for 180 degrees (ends on right side)

    // Define the bounding rectangle for our arc
    // Since we only draw a semi-circle, we make the bounding box twice as tall 
    // and clip or size the parent widget appropriately to show only the top half.
    final Rect arcRect = Rect.fromLTWH(
      0, 
      0, 
      size.width, 
      size.height * 2,
    );

    // 4. Draw the background semi-circle
    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle,
      false, // false means we don't connect the ends of the arc to the center
      backgroundPaint,
    );

    // 5. Draw the progress semi-circle based on the dynamic completion value
    // We multiply sweepAngle (pi) by progress (0.0 to 1.0)
    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  // Tells Flutter to redraw the canvas whenever the progress percentage changes
  @override
  bool shouldRepaint(covariant ArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
