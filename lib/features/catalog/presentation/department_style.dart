import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/features/catalog/domain/department.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:flutter/material.dart';

/// Turns department data into colours and icons. Kept out of the domain
/// layer so the models never depend on Flutter.
Color colorFromHex(String hex) =>
    Color(int.parse(hex.replaceFirst('#', ''), radix: 16) | 0xFF000000);

IconData iconForDepartment(String slug) => switch (slug) {
      'groceries' => Icons.local_grocery_store_outlined,
      'fashion' => Icons.checkroom_outlined,
      'electronics' => Icons.headphones_outlined,
      'home' => Icons.chair_outlined,
      _ => Icons.category_outlined,
    };

extension DepartmentStyle on Department {
  Color get tint => colorFromHex(tintHex);

  /// A darker shade of the tint for icons drawn on top of it.
  Color get deepTint => Color.lerp(tint, BkColors.ink, 0.45)!;

  IconData get icon => iconForDepartment(slug);
}

extension ProductStyle on Product {
  /// The department colour that came with the product, or pale plum.
  Color get tint =>
      departmentTintHex == null ? BkColors.soft : colorFromHex(departmentTintHex!);

  Color get deepTint => Color.lerp(tint, BkColors.ink, 0.45)!;

  IconData get icon => iconForDepartment(departmentSlug);
}
