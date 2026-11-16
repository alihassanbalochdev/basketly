import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Looks like a search box on Home; tapping it opens the search screen,
/// where the real text field is.
class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search',
      child: Material(
        color: BkColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(26)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(26)),
          onTap: () => context.go('/home/search'),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: BkSpace.md),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(26)),
              boxShadow: BkShadow.subtle,
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: BkColors.muted),
                SizedBox(width: BkSpace.md),
                Text('Search milk, kurtas, phones…', style: BkText.small),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
