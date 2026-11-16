import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/features/catalog/domain/department.dart';
import 'package:flutter/material.dart';

/// "All", then one pill per department. Scrolls sideways.
class DepartmentChips extends StatelessWidget {
  const DepartmentChips({
    super.key,
    required this.departments,
    required this.selected,
    required this.onSelected,
  });

  final List<Department> departments;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(String?, String)>[
      (null, 'All'),
      for (final d in departments) (d.slug, d.name),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: BkSpace.xl),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: BkSpace.sm),
        itemBuilder: (context, index) {
          final (slug, label) = options[index];
          final isOn = slug == selected;

          return ChoiceChip(
            label: Text(label),
            selected: isOn,
            onSelected: (_) => onSelected(slug),
            showCheckmark: false,
            shape: const StadiumBorder(),
            side: BorderSide.none,
            backgroundColor: BkColors.surface,
            selectedColor: BkColors.plum,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
              color: isOn ? Colors.white : BkColors.ink,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          );
        },
      ),
    );
  }
}
