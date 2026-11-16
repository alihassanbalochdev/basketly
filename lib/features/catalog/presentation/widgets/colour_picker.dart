import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:flutter/material.dart';

class ColourPicker extends StatelessWidget {
  const ColourPicker({
    super.key,
    required this.colours,
    required this.selected,
    required this.onSelected,
  });

  final List<ProductColour> colours;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Colour  ', style: BkText.label),
            TextSpan(text: colours[selected].name, style: BkText.small),
          ]),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            for (final (index, colour) in colours.indexed)
              Semantics(
                selected: index == selected,
                button: true,
                label: colour.name,
                child: InkResponse(
                  onTap: () => onSelected(index),
                  radius: 24,
                  child: SizedBox.square(
                    dimension: 44,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorFromHex(colour.hex),
                          shape: BoxShape.circle,
                          border: Border.all(color: BkColors.line),
                          // Selected: a plum ring with a small gap.
                          boxShadow: index == selected
                              ? const [
                                  BoxShadow(color: BkColors.background, spreadRadius: 2),
                                  BoxShadow(color: BkColors.plum, spreadRadius: 4),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
