import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/widgets/round_icon_button.dart';
import 'package:basketly/features/orders/domain/order.dart';
import 'package:basketly/features/orders/domain/order_progress.dart';
import 'package:flutter/material.dart';

/// The plum top of the tracking screen: when it arrives, and a bar with
/// the scooter riding towards the house.
class TrackingHero extends StatelessWidget {
  const TrackingHero({
    super.key,
    required this.order,
    required this.stage,
    required this.now,
    required this.onBack,
  });

  final Order order;
  final OrderStage stage;
  final DateTime now;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final (heading, big) = switch (stage) {
      OrderStage.delivered => (
          'Delivered ${dayWord(stageTime(order, stage), now)}',
          clockTime(stageTime(order, stage)),
        ),
      OrderStage.cancelled => ('This order was', 'Cancelled'),
      _ => ('Arriving ${dayWord(order.slotStart, now)}', order.slotHours),
    };

    return Container(
      decoration: const BoxDecoration(
        color: BkColors.plum,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      padding: EdgeInsets.fromLTRB(
        BkSpace.xl, MediaQuery.paddingOf(context).top + BkSpace.lg, BkSpace.xl, 26,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoundIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: onBack,
                background: Colors.white.withValues(alpha: 0.12),
                foreground: Colors.white,
              ),
              Text('Order ${order.number}',
                  style: const TextStyle(fontSize: 13, color: BkColors.plumOnDark)),
            ],
          ),
          const SizedBox(height: 18),
          Text(heading, style: const TextStyle(fontSize: 14, color: BkColors.plumOnDark)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              big,
              style: const TextStyle(
                fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1.1,
                height: 1.05, color: BkColors.saffron,
              ),
            ),
          ),
          if (stage != OrderStage.cancelled) ...[
            const SizedBox(height: 18),
            _RideBar(progress: stageProgress(stage)),
          ],
        ],
      ),
    );
  }
}

class _RideBar extends StatelessWidget {
  const _RideBar({required this.progress});

  final double progress;

  static const _dot = 34.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _dot,
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth;
          // The scooter slides along when the stage changes.
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              final left = (width * value - _dot / 2).clamp(0.0, width - _dot);
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  _track(width, Colors.white.withValues(alpha: 0.16)),
                  _track(width * value, BkColors.saffron),
                  Positioned(
                    right: 0,
                    child: _circle(
                      value >= 1 ? BkColors.saffron : Colors.white.withValues(alpha: 0.12),
                      Icon(Icons.home_rounded, size: 18,
                          color: value >= 1 ? BkColors.plum : Colors.white),
                    ),
                  ),
                  if (value < 1)
                    Positioned(
                      left: left,
                      child: _circle(
                        BkColors.saffron,
                        const Icon(Icons.delivery_dining_rounded, size: 20, color: BkColors.plum),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _track(double width, Color color) => Container(
        width: width,
        height: 6,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      );

  Widget _circle(Color color, Widget icon) => Container(
        width: _dot,
        height: _dot,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: icon,
      );
}
