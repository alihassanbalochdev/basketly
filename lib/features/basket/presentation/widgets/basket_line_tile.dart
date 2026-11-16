import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/widgets/price_text.dart';
import 'package:basketly/core/widgets/product_image.dart';
import 'package:basketly/features/basket/domain/basket_line.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/basket/presentation/widgets/quantity_pill.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasketLineTile extends StatelessWidget {
  const BasketLineTile({super.key, required this.line});

  final BasketLine line;

  /// Removes the line and offers Undo for a few seconds.
  static void removeWithUndo(BuildContext context, BasketLine line) {
    final basket = context.read<BasketCubit>();
    final removed = basket.remove(line.key);
    if (removed == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${removed.product.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: BkColors.saffron,
            onPressed: () => basket.restoreLine(removed),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = line.product;
    final detail = line.optionsLabel.isNotEmpty ? line.optionsLabel : product.subtitle;

    return Dismissible(
      key: ValueKey(line.key),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => removeWithUndo(context, line),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: BkSpace.xxl),
        decoration: const BoxDecoration(color: BkColors.soft, borderRadius: BkRadius.card),
        child: const Icon(Icons.delete_outline_rounded, color: BkColors.plum),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
        decoration: const BoxDecoration(color: BkColors.surface, borderRadius: BkRadius.card),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: product.tint, borderRadius: BkRadius.small),
              child: ProductImage(
                imageUrl: product.imageUrl,
                fallbackIcon: product.icon,
                size: 56,
                iconColor: product.deepTint,
              ),
            ),
            const SizedBox(width: BkSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BkText.label.copyWith(fontSize: 14)),
                  if (detail.isNotEmpty)
                    Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: BkText.tiny),
                  const SizedBox(height: 2),
                  PriceText(price: line.total, size: 15),
                ],
              ),
            ),
            QuantityPill(
              quantity: line.quantity,
              itemName: product.name,
              onChanged: (quantity) => quantity <= 0
                  ? removeWithUndo(context, line)
                  : context.read<BasketCubit>().setQuantity(line.key, quantity),
            ),
          ],
        ),
      ),
    );
  }
}
