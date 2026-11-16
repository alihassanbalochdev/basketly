import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/utils/money.dart';
import 'package:basketly/features/checkout/domain/placed_order.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key, required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final paidBy = order.paymentMethod == 'cod' ? 'Pay ${rs(order.total)} on delivery' : 'Paid ${rs(order.total)} (demo)';

    return Scaffold(
      backgroundColor: BkColors.plum,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(BkSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: BkColors.saffron, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 40, color: BkColors.plum),
              ),
              const SizedBox(height: BkSpace.xl),
              Text('Order placed', style: BkText.display.copyWith(color: Colors.white)),
              const SizedBox(height: BkSpace.sm),
              Text('Order ${order.number}', style: const TextStyle(color: BkColors.plumOnDark, fontSize: 15)),
              const SizedBox(height: BkSpace.xxl),
              _Line(icon: Icons.schedule_rounded, text: order.slotLabel),
              _Line(icon: Icons.payments_outlined, text: paidBy),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: () => context.go('/order/${order.id}'),
                style: FilledButton.styleFrom(
                  backgroundColor: BkColors.saffron,
                  foregroundColor: BkColors.ink,
                  minimumSize: const Size.fromHeight(56),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Track order'),
              ),
              const SizedBox(height: BkSpace.sm),
              TextButton(
                onPressed: () => context.go('/home'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Keep shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BkSpace.md),
      child: Row(
        children: [
          Icon(icon, color: BkColors.saffron, size: 22),
          const SizedBox(width: BkSpace.md),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }
}
