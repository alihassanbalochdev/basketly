import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/widgets/product_image.dart';
import 'package:basketly/features/catalog/domain/department.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DepartmentGrid extends StatelessWidget {
  const DepartmentGrid({super.key, required this.departments});

  final List<Department> departments;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: BkSpace.md,
      crossAxisSpacing: BkSpace.md,
      childAspectRatio: 175 / 118,
      // The page itself scrolls; this grid just lays out its tiles.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [for (final d in departments) _DepartmentTile(department: d)],
    );
  }
}

class _DepartmentTile extends StatelessWidget {
  const _DepartmentTile({required this.department});

  final Department department;

  static final _count = NumberFormat.decimalPattern('en_US');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: department.tint,
      borderRadius: BkRadius.tile,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/browse?dept=${department.slug}'),
        child: Stack(
          children: [
            // Illustration peeking out of the corner, cut off by the tile.
            // Until it loads (or with no image) the big icon shows instead.
            // It's first in the Stack, so the name is drawn on top of it.
            Positioned(
              right: -10,
              bottom: -14,
              child: ProductImage(
                imageUrl: department.imageUrl,
                fallbackIcon: department.icon,
                size: 116,
                iconColor: department.deepTint,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(department.name, style: BkText.heading.copyWith(fontSize: 18)),
                  const SizedBox(height: 3),
                  Text('${_count.format(department.itemCount)} items', style: BkText.tiny),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
