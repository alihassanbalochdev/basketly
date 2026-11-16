import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_icon.dart';
import 'package:flutter/material.dart';

/// The plum basket button: big and raised in the nav bar, small in
/// a page header. It bounces whenever the item count goes up.
class BasketButton extends StatefulWidget {
  const BasketButton({
    super.key,
    required this.count,
    required this.fill,
    required this.onTap,
    this.size = 64,
    this.ringColor = BkColors.background,
  });

  final int count;
  final double fill;
  final VoidCallback onTap;
  final double size;
  final Color ringColor; // the gap ring around it, matching what's behind

  @override
  State<BasketButton> createState() => _BasketButtonState();
}

class _BasketButtonState extends State<BasketButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );

  // Grow, overshoot back a little, settle: feels like something landed.
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.22), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.22, end: 0.94), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 0.94, end: 1), weight: 30),
  ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeOut));

  @override
  void didUpdateWidget(BasketButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.count > oldWidget.count && !reduceMotion) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final big = widget.size >= 56;

    return Semantics(
      button: true,
      label: 'Basket, ${widget.count} items',
      child: ScaleTransition(
        scale: _scale,
        child: Material(
          color: BkColors.plum,
          shape: CircleBorder(
            side: big
                ? BorderSide(color: widget.ringColor, width: 4)
                : BorderSide.none,
          ),
          elevation: big ? 8 : 3,
          shadowColor: BkColors.plum.withValues(alpha: 0.5),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            child: SizedBox.square(
              dimension: widget.size,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  BasketIcon(fill: widget.fill, size: widget.size * 0.47),
                  if (widget.count > 0)
                    Positioned(
                      top: big ? -6 : -5,
                      right: big ? -6 : -5,
                      child: _CountBadge(count: widget.count, ring: widget.ringColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.ring});

  final int count;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: BkColors.saffron,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: ring, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: BkColors.ink),
      ),
    );
  }
}
