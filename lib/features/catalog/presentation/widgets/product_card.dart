import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/widgets/price_text.dart';
import 'package:basketly/core/widgets/product_image.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_targets.dart';
import 'package:basketly/features/basket/presentation/widgets/fly_to_basket.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:basketly/features/catalog/presentation/widgets/flying_thumb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, this.tint, this.iconColor});

  final Product product;
  final Color? tint;
  final Color? iconColor;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final _addKey = GlobalKey(); // where the flying picture starts

  void _open() => context.push('/product/${widget.product.id}');

  void _quickAdd() {
    final product = widget.product;
    // Sizes or colours to choose: the product page asks for them.
    if (!product.canQuickAdd) return _open();

    final basket = context.read<BasketCubit>();
    FlyToBasket.launch(
      context: context,
      from: _addKey,
      to: navBasketKey,
      child: FlyingThumb(product: product, tint: widget.tint, iconColor: widget.iconColor),
      onLanded: () => basket.add(product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final discount = product.discountPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 190,
          child: Stack(
            children: [
              Positioned.fill(
                child: Material(
                  color: widget.tint ?? BkColors.soft,
                  borderRadius: BkRadius.tile,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _open,
                    child: Center(
                      child: ProductImage(
                        imageUrl: product.imageUrl,
                        fallbackIcon: iconForDepartment(product.departmentSlug),
                        size: 130,
                        iconColor: widget.iconColor ?? BkColors.plum,
                      ),
                    ),
                  ),
                ),
              ),
              if (discount != null)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: BkColors.saffron,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '−$discount%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: BkColors.ink),
                    ),
                  ),
                ),
              Positioned(
                right: 8,
                bottom: 8,
                child: IconButton(
                  key: _addKey,
                  tooltip: product.canQuickAdd ? 'Add ${product.name}' : 'Choose options for ${product.name}',
                  onPressed: _quickAdd,
                  style: IconButton.styleFrom(
                    backgroundColor: BkColors.plum,
                    fixedSize: const Size(44, 44),
                    elevation: 4,
                    shadowColor: BkColors.plum.withValues(alpha: 0.4),
                  ),
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BkSpace.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BkText.label.copyWith(fontSize: 14)),
              const SizedBox(height: 2),
              Text(product.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: BkText.tiny),
              const SizedBox(height: 4),
              PriceText(price: product.price, wasPrice: product.wasPrice),
            ],
          ),
        ),
      ],
    );
  }
}
