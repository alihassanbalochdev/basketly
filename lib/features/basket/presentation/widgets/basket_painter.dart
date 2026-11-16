import 'package:flutter/material.dart';

/// Draws the Basketly basket and fills it from the bottom.
/// Coordinates are on a 32 x 32 grid and scaled to any size.
class BasketPainter extends CustomPainter {
  BasketPainter({
    required this.fill,
    required this.fillColor,
    required this.lineColor,
  });

  final double fill; // 0.0 empty .. 1.0 full
  final Color fillColor;
  final Color lineColor;

  static final Path _body = Path()
    ..moveTo(5, 12)
    ..lineTo(27, 12)
    ..lineTo(24.6, 24.2)
    ..arcToPoint(const Offset(21.7, 27), radius: const Radius.circular(3))
    ..lineTo(10.3, 27)
    ..arcToPoint(const Offset(7.4, 24.2), radius: const Radius.circular(3))
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 32);

    // 1. The fill: a rectangle clipped to the basket's shape.
    //    The basket body runs from y = 12 to y = 27 (15 units tall).
    canvas.save();
    canvas.clipPath(_body);
    final top = 12 + 15 * (1 - fill);
    canvas.drawRect(Rect.fromLTRB(0, top, 32, 32), Paint()..color = fillColor);
    canvas.restore();

    // 2. The outline and the two handles on top.
    final stroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_body, stroke);
    canvas.drawLine(const Offset(11, 12), const Offset(15, 5), stroke);
    canvas.drawLine(const Offset(21, 12), const Offset(17, 5), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(BasketPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.lineColor != lineColor;
}
