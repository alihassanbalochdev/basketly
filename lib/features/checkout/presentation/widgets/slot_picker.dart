import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/features/checkout/domain/delivery_slot.dart';
import 'package:flutter/material.dart';

class SlotPicker extends StatelessWidget {
  const SlotPicker({super.key, required this.slots, required this.selected, required this.onSelected});

  final List<DeliverySlot> slots;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: slots.length,
        separatorBuilder: (context, index) => const SizedBox(width: BkSpace.sm),
        itemBuilder: (context, index) {
          // "Today, 6 PM–8 PM" -> day on top, hours below.
          final (day, hours) = switch (slots[index].label.split(', ')) {
            [final d, final h] => (d, h),
            _ => ('', slots[index].label),
          };
          final isOn = index == selected;

          return Semantics(
            selected: isOn,
            button: true,
            child: Material(
              color: isOn ? BkColors.plum : BkColors.surface,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(index),
                child: Container(
                  width: 128,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day, style: TextStyle(fontSize: 12, color: isOn ? BkColors.plumOnDark : BkColors.muted)),
                      Text(
                        hours,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isOn ? Colors.white : BkColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
