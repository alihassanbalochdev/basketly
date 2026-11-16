import 'package:basketly/core/theme/bk_colors.dart';
import 'package:flutter/material.dart';

/// Address, Delivery, Payment: a bar fills as each part is ready.
class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key, required this.addressDone, required this.slotDone});

  final bool addressDone;
  final bool slotDone;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Address', addressDone),
      ('Delivery', addressDone && slotDone),
      ('Payment', false),
    ];
    // The first unfinished step is the current one.
    final current = steps.indexWhere((s) => !s.$2);

    return Row(
      children: [
        for (final (index, (label, done)) in steps.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 5,
                  decoration: BoxDecoration(
                    color: done
                        ? BkColors.plum
                        : index == current
                            ? BkColors.saffron
                            : BkColors.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: index == current ? FontWeight.w700 : FontWeight.w500,
                    color: done || index == current ? BkColors.ink : BkColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
