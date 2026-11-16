import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_painter.dart';
import 'package:flutter/material.dart';

/// The basket drawing, with the saffron level gliding to its new height.
class BasketIcon extends StatelessWidget {
  const BasketIcon({
    super.key,
    required this.fill,
    this.size = 30,
    this.lineColor = Colors.white,
  });

  final double fill;
  final double size;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    // Animates from the previous value to the new `fill` on every change.
    return TweenAnimationBuilder<double>(
      tween: Tween(end: fill),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: BasketPainter(
            fill: value,
            fillColor: BkColors.saffron,
            lineColor: lineColor,
          ),
        ),
      ),
    );
  }
}
