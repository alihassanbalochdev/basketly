import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/orders/domain/order.dart';
import 'package:basketly/features/orders/domain/order_progress.dart';
import 'package:flutter/material.dart';

typedef _Step = ({OrderStage stage, String title, String detail});

/// Placed, Packed, On the way, Delivered, with a line joining the dots.
class TrackingTimeline extends StatelessWidget {
  const TrackingTimeline({super.key, required this.order, required this.stage, required this.now});

  final Order order;
  final OrderStage stage;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final items = order.itemCount == 1 ? '1 item' : '${order.itemCount} items';
    final departments =
        order.departmentCount == 1 ? '1 department' : '${order.departmentCount} departments';

    final steps = <_Step>[
      (
        stage: OrderStage.placed,
        title: 'Order placed',
        detail: order.paymentMethod == 'cod' ? 'Cash on delivery' : 'Paid by card (demo)',
      ),
      (stage: OrderStage.packed, title: 'Packed', detail: '$items from $departments'),
      (stage: OrderStage.onTheWay, title: 'On the way', detail: 'Your rider is heading to you'),
      (stage: OrderStage.delivered, title: 'Delivered', detail: 'Hand-off at your door'),
    ];

    return Column(
      children: [
        for (final (index, step) in steps.indexed)
          _StepRow(
            step: step,
            done: step.stage.index < stage.index || stage == OrderStage.delivered,
            current: step.stage == stage && stage != OrderStage.delivered,
            isLast: index == steps.length - 1,
            time: step.stage.index <= stage.index && stageTime(order, step.stage).isBefore(now)
                ? clockTime(stageTime(order, step.stage))
                : null,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.done,
    required this.current,
    required this.isLast,
    required this.time,
  });

  final _Step step;
  final bool done;
  final bool current;
  final bool isLast;
  final String? time;

  @override
  Widget build(BuildContext context) {
    final dot = switch ((done, current)) {
      (true, _) => Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(color: BkColors.plum, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
        ),
      (_, true) => Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(
            color: BkColors.saffron,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x40F2A20C), spreadRadius: 6)],
          ),
        ),
      _ => Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: BkColors.line, width: 2),
          ),
        ),
    };

    // IntrinsicHeight lets the joining line stretch to the text's height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                dot,
                if (!isLast) ...[
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(minHeight: 22),
                      decoration: BoxDecoration(
                        color: done ? BkColors.plum : BkColors.line,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: BkText.body.copyWith(
                            fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                            color: done || current ? BkColors.ink : BkColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(step.detail, style: BkText.small),
                      ],
                    ),
                  ),
                  if (time case final t?) Text(t, style: BkText.small),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
