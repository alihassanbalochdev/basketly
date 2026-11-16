import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/utils/money.dart';
import 'package:basketly/features/orders/domain/order.dart';
import 'package:basketly/features/orders/domain/order_progress.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final stage = stageOf(order, now);
    final active = stage != OrderStage.delivered && stage != OrderStage.cancelled;
    final items = order.itemCount == 1 ? '1 item' : '${order.itemCount} items';

    return Material(
      color: BkColors.surface,
      borderRadius: BkRadius.card,
      child: InkWell(
        borderRadius: BkRadius.card,
        onTap: () => context.push('/order/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(BkSpace.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: active ? BkColors.plum : BkColors.soft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  active ? Icons.delivery_dining_rounded : Icons.inventory_2_outlined,
                  color: active ? BkColors.saffron : BkColors.plum,
                ),
              ),
              const SizedBox(width: BkSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.number, style: BkText.bodyStrong),
                    const SizedBox(height: 2),
                    Text('${listDate(order.createdAt)}, $items', style: BkText.small),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(rs(order.total), style: BkText.price),
                  const SizedBox(height: 4),
                  _StageChip(stage: stage),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({required this.stage});

  final OrderStage stage;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (stage) {
      OrderStage.delivered => (BkColors.soft, BkColors.plum),
      OrderStage.cancelled => (BkColors.line, BkColors.muted),
      _ => (const Color(0xFFFDF0D5), const Color(0xFF8A5A00)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(stageName(stage),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground)),
    );
  }
}
