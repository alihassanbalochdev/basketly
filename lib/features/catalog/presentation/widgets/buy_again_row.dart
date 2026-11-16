import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/widgets/price_text.dart';
import 'package:basketly/core/widgets/product_image.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/catalog/domain/department.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BuyAgainRow extends StatelessWidget {
  const BuyAgainRow({super.key, required this.products, required this.departments});

  final List<Product> products;
  final List<Department> departments;

  @override
  Widget build(BuildContext context) {
    final bySlug = {for (final d in departments) d.slug: d};

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          return _BuyAgainCard(
            product: product,
            department: bySlug[product.departmentSlug],
          );
        },
      ),
    );
  }
}

class _BuyAgainCard extends StatelessWidget {
  const _BuyAgainCard({required this.product, required this.department});

  final Product product;
  final Department? department;

  @override
  Widget build(BuildContext context) {
    // Rebuilds only when *this* product's in-basket flag changes.
    final inBasket = context.select<BasketCubit, bool>(
      (cubit) => cubit.state.contains(product.id),
    );

    return Material(
      color: BkColors.surface,
      borderRadius: BkRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/product/${product.id}'),
        child: Container(
      width: 204,
      padding: const EdgeInsets.all(BkSpace.sm),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: department?.tint ?? BkColors.soft,
              borderRadius: BkRadius.small,
            ),
            child: ProductImage(
              imageUrl: product.imageUrl,
              fallbackIcon: iconForDepartment(product.departmentSlug),
              size: 56,
              iconColor: department?.deepTint ?? BkColors.plum,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BkText.label),
                const SizedBox(height: 2),
                PriceText(price: product.price, size: 14),
              ],
            ),
          ),
          _AddButton(
            inBasket: inBasket,
            label: product.name,
            onPressed: () => context.read<BasketCubit>().add(product),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.inBasket, required this.label, required this.onPressed});

  final bool inBasket;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: inBasket ? '$label is in your basket' : 'Add $label',
      onPressed: inBasket ? null : onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      style: IconButton.styleFrom(
        backgroundColor: BkColors.saffron,
        disabledBackgroundColor: BkColors.soft,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          inBasket ? Icons.check_rounded : Icons.add_rounded,
          key: ValueKey(inBasket),
          color: inBasket ? BkColors.plum : BkColors.ink,
          size: 20,
        ),
      ),
    );
  }
}
