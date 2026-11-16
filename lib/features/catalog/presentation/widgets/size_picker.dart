import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:flutter/material.dart';

class SizePicker extends StatelessWidget {
  const SizePicker({
    super.key,
    required this.sizes,
    required this.soldOut,
    required this.selected,
    required this.onSelected,
  });

  final List<String> sizes;
  final List<String> soldOut;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Size  ', style: BkText.label),
            TextSpan(text: selected ?? 'Choose one', style: BkText.small),
          ]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final size in sizes)
              _SizeButton(
                label: size,
                isSelected: size == selected,
                isSoldOut: soldOut.contains(size),
                onTap: () => onSelected(size),
              ),
          ],
        ),
      ],
    );
  }
}

class _SizeButton extends StatelessWidget {
  const _SizeButton({
    required this.label,
    required this.isSelected,
    required this.isSoldOut,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isSoldOut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch ((isSelected, isSoldOut)) {
      (_, true) => (Colors.transparent, const Color(0xFFB3A9B6)),
      (true, _) => (BkColors.plum, Colors.white),
      _ => (BkColors.surface, BkColors.ink),
    };

    return Semantics(
      label: isSoldOut ? 'Size $label, sold out' : 'Size $label',
      selected: isSelected,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isSoldOut ? const BorderSide(color: BkColors.line) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isSoldOut ? null : onTap,
          child: SizedBox(
            width: 58,
            height: 46,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: foreground,
                  decoration: isSoldOut ? TextDecoration.lineThrough : null,
                  decorationColor: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
