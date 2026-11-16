import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/utils/money.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_icon.dart';
import 'package:flutter/material.dart';

/// Plum card: the filling basket plus "Add Rs 1,210 more for free delivery".
class FreeDeliveryCard extends StatelessWidget {
  const FreeDeliveryCard({super.key, required this.progress, required this.amountLeft});

  final double progress; // 0..1
  final int amountLeft;

  @override
  Widget build(BuildContext context) {
    final unlocked = amountLeft == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(color: BkColors.plum, borderRadius: BkRadius.card),
      child: Row(
        children: [
          BasketIcon(fill: progress, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unlocked ? 'Free delivery unlocked' : 'Add ${rs(amountLeft)} more for free delivery',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      color: BkColors.saffron,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
