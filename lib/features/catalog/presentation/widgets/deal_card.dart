import 'dart:math' as math;

import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/widgets/price_text.dart';
import 'package:basketly/core/widgets/product_image.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:basketly/features/catalog/presentation/widgets/deal_countdown.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The plum "Deal of the hour" card. The product image deliberately
/// breaks out of the card's top edge, and a tilted saffron sticker
/// shows the discount.
class DealCard extends StatelessWidget {
  const DealCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

    return Semantics(
      button: true,
      label: 'Deal of the hour: ${product.name}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/product/${product.id}'),
        child: SizedBox(
      height: 184,
      child: Stack(
        clipBehavior: Clip.none, // lets the image overflow the card
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: BkColors.plum, borderRadius: BkRadius.hero),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: 190,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deal of the hour',
                    style: BkText.label.copyWith(color: BkColors.saffron),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: BkText.heading.copyWith(fontSize: 22, color: Colors.white),
                  ),
                  const Spacer(),
                  PriceText(
                    price: product.price,
                    wasPrice: product.wasPrice,
                    size: 20,
                    color: BkColors.saffron,
                    wasColor: BkColors.plumOnDark,
                  ),
                  const SizedBox(height: 8),
                  const DealCountdown(),
                ],
              ),
            ),
          ),
          Positioned(
            right: -6,
            top: -42,
            child: ProductImage(
              imageUrl: product.imageUrl,
              fallbackIcon: iconForDepartment(product.departmentSlug),
              size: 176,
              iconColor: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (discount != null)
            Positioned(
              right: 16,
              bottom: 16,
              child: Transform.rotate(
                angle: -10 * math.pi / 180,
                child: Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: BkColors.saffron,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '−$discount%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: BkColors.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
        ),
      ),
    );
  }
}
