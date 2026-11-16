import 'package:basketly/core/theme/bk_colors.dart';
import 'package:flutter/material.dart';

/// − 2 + in a soft pill. Going below 1 is the caller's decision.
class QuantityPill extends StatelessWidget {
  const QuantityPill({
    super.key,
    required this.quantity,
    required this.onChanged,
    required this.itemName,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, String tooltip, int next) => IconButton(
          tooltip: tooltip,
          onPressed: () => onChanged(next),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 44),
          style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          icon: Icon(icon, size: 18, color: BkColors.ink),
        );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: BkColors.background,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            quantity == 1 ? 'Remove $itemName' : 'One fewer $itemName',
            quantity - 1,
          ),
          SizedBox(
            width: 18,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          button(Icons.add_rounded, 'One more $itemName', quantity + 1),
        ],
      ),
    );
  }
}
