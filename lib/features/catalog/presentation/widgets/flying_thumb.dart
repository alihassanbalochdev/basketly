import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/widgets/product_image.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:flutter/material.dart';

/// The round picture of a product that flies into the basket.
class FlyingThumb extends StatelessWidget {
  const FlyingThumb({super.key, required this.product, this.tint, this.iconColor});

  final Product product;
  final Color? tint;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint ?? BkColors.soft,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: BkColors.plum.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ProductImage(
        imageUrl: product.imageUrl,
        fallbackIcon: iconForDepartment(product.departmentSlug),
        size: 48,
        iconColor: iconColor ?? BkColors.plum,
      ),
    );
  }
}
