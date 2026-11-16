import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:flutter/material.dart';

/// Floating white pill at the bottom of the product page:
/// quantity stepper on the left, "Add to basket" on the right.
class AddToBasketBar extends StatelessWidget {
  const AddToBasketBar({
    super.key,
    required this.addButtonKey,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAdd,
    required this.label,
  });

  final GlobalKey addButtonKey;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback? onAdd; // null disables the button
  final String label;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 68,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: const BoxDecoration(
          color: BkColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(34)),
          boxShadow: BkShadow.floating,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: BkColors.background,
                borderRadius: BorderRadius.all(Radius.circular(26)),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Fewer',
                    onPressed: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  SizedBox(
                    width: 18,
                    child: Text(
                      '$quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'More',
                    onPressed: quantity < 9 ? () => onQuantityChanged(quantity + 1) : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                key: addButtonKey,
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: BkColors.plum,
                  disabledBackgroundColor: BkColors.soft,
                  disabledForegroundColor: BkColors.muted,
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(label, key: ValueKey(label)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
