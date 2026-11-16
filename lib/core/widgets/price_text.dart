import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/utils/money.dart';
import 'package:flutter/material.dart';

/// "Rs 3,290", optionally followed by the old price struck through.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.wasPrice,
    this.size = 16,
    this.color = BkColors.ink,
    this.wasColor = BkColors.muted,
  });

  final int price;
  final int? wasPrice;
  final double size;
  final Color color;
  final Color wasColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(rs(price), style: BkText.price.copyWith(fontSize: size, color: color)),
        if (wasPrice case final was?) ...[
          const SizedBox(width: 8),
          Text(
            rs(was),
            style: BkText.small.copyWith(
              color: wasColor,
              decoration: TextDecoration.lineThrough,
              decorationColor: wasColor,
            ),
          ),
        ],
      ],
    );
  }
}
