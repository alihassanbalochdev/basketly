import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/utils/money.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:basketly/features/orders/domain/order.dart';
import 'package:flutter/material.dart';

/// What was ordered, the address, and the totals worked out by the server.
class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BkSpace.lg),
      decoration: const BoxDecoration(color: BkColors.surface, borderRadius: BkRadius.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your items', style: BkText.heading),
          const SizedBox(height: BkSpace.md),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: BkSpace.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: BkColors.soft, borderRadius: BkRadius.small),
                    child: Icon(iconForDepartment(item.departmentSlug ?? ''),
                        size: 20, color: BkColors.plum),
                  ),
                  const SizedBox(width: BkSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.quantity} × ${item.name}', style: BkText.label),
                        if (item.optionsLabel.isNotEmpty) Text(item.optionsLabel, style: BkText.tiny),
                      ],
                    ),
                  ),
                  Text(rs(item.lineTotal), style: BkText.label),
                ],
              ),
            ),
          const Divider(color: BkColors.line, height: BkSpace.xl),
          _Row('Subtotal', rs(order.subtotal)),
          if (order.discount > 0) _Row('Promo', '– ${rs(order.discount)}'),
          _Row('Delivery', order.deliveryFee == 0 ? 'Free' : rs(order.deliveryFee)),
          const SizedBox(height: BkSpace.xs),
          _Row('Total', rs(order.total), strong: true),
          if (order.addressLine.isNotEmpty) ...[
            const Divider(color: BkColors.line, height: BkSpace.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: BkColors.muted),
                const SizedBox(width: BkSpace.sm),
                Expanded(child: Text(order.addressLine, style: BkText.small)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong ? BkText.price : BkText.small;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: strong ? BkText.bodyStrong : BkText.small),
          Text(value, style: style),
        ],
      ),
    );
  }
}
