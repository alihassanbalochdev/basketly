import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/catalog/domain/browse_sort.dart';
import 'package:flutter/material.dart';

/// "Most popular ⌄" that opens a sheet of sort options.
class SortButton extends StatelessWidget {
  const SortButton({super.key, required this.sort, required this.onSelected});

  final BrowseSort sort;
  final ValueChanged<BrowseSort> onSelected;

  Future<void> _openSheet(BuildContext context) async {
    final choice = await showModalBottomSheet<BrowseSort>(
      context: context,
      showDragHandle: true,
      backgroundColor: BkColors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Sort by', style: BkText.heading),
            ),
            for (final option in BrowseSort.values)
              ListTile(
                title: Text(option.label, style: BkText.body),
                trailing: option == sort
                    ? const Icon(Icons.check_rounded, color: BkColors.plum)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice != null) onSelected(choice);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _openSheet(context),
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: BkColors.muted),
      label: Text(sort.label, style: BkText.small),
    );
  }
}
