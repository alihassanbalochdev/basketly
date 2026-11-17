import 'dart:math' as math;

import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The animated opening. It starts on exactly what the native launch
/// screen shows (the saffron basket on plum), so the hand-over is seamless.
/// Then products drop into the basket, it bounces, and the name appears.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2100))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) context.go('/home');
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // People who turn animations off in Android settings skip straight in.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = const Duration(milliseconds: 400);
    }
    if (!_controller.isAnimating && !_controller.isCompleted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkColors.plum,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          // 0.45 → 0.80: the basket rises and the name slides in under it.
          final reveal = Curves.easeOutCubic.transform(((t - 0.45) / 0.35).clamp(0.0, 1.0));

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, 36 * (1 - reveal)),
                  child: SizedBox.square(
                    dimension: 112,
                    child: CustomPaint(painter: _BasketPainter(t)),
                  ),
                ),
                const SizedBox(height: 18),
                Opacity(
                  opacity: reveal,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - reveal)),
                    child: Column(
                      children: [
                        Text(
                          'Basketly',
                          style: BkText.display.copyWith(color: Colors.white, fontSize: 40, letterSpacing: -1.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Groceries, fashion, electronics and home',
                          style: BkText.body.copyWith(color: BkColors.plumOnDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The basket from the app icon, drawn on a 1024-unit grid, with three
/// items (one per department colour) dropping in between 10% and 50%.
class _BasketPainter extends CustomPainter {
  _BasketPainter(this.t);

  final double t;

  static const _items = [
    (color: Color(0xFF7FC08A), x: 420.0, start: 0.10), // groceries green
    (color: Color(0xFFEFA3B6), x: 600.0, start: 0.20), // fashion pink
    (color: Color(0xFF8FB2E8), x: 510.0, start: 0.30), // electronics blue
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 1024;
    canvas.scale(s);
    canvas.translate(0, 40); // centre the basket's weight in the square

    // Each landing squashes the basket a little, then it springs back.
    var squash = 0.0;
    for (final item in _items) {
      final since = t - (item.start + 0.12);
      if (since > 0 && since < 0.12) squash = math.max(squash, math.sin(since / 0.12 * math.pi) * 0.06);
    }
    canvas.save();
    canvas.translate(512, 744);
    canvas.scale(1 + squash, 1 - squash);
    canvas.translate(-512, -744);

    final saffron = Paint()..color = BkColors.saffron;

    // Items behind the rim, falling from above.
    for (final item in _items) {
      final p = ((t - item.start) / 0.12).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final y = -120 + Curves.easeIn.transform(p) * 450; // ends peeking over the rim
      canvas.drawCircle(Offset(item.x, y), 70, Paint()..color = item.color);
    }

    // Handle.
    canvas.drawPath(
      Path()
        ..moveTo(372, 300)
        ..quadraticBezierTo(372, 170, 512, 170)
        ..quadraticBezierTo(652, 170, 652, 300),
      Paint()
        ..color = BkColors.saffron
        ..style = PaintingStyle.stroke
        ..strokeWidth = 56
        ..strokeCap = StrokeCap.round,
    );

    // Body.
    canvas.drawPath(
      Path()
        ..moveTo(248, 400)
        ..lineTo(776, 400)
        ..lineTo(736, 700)
        ..quadraticBezierTo(728, 744, 684, 744)
        ..lineTo(340, 744)
        ..quadraticBezierTo(296, 744, 288, 700)
        ..close(),
      saffron,
    );

    // Rim.
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(196, 318, 632, 96), const Radius.circular(48)),
      Paint()..color = const Color(0xFFFFC447),
    );

    // Slats.
    final slat = Paint()
      ..color = BkColors.plum.withValues(alpha: 0.85)
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(378, 470), const Offset(392, 680), slat);
    canvas.drawLine(const Offset(512, 470), const Offset(512, 686), slat);
    canvas.drawLine(const Offset(646, 470), const Offset(632, 680), slat);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BasketPainter oldDelegate) => oldDelegate.t != t;
}
