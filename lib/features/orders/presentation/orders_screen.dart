import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/catalog/presentation/widgets/home_error_view.dart';
import 'package:basketly/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:basketly/features/orders/presentation/cubit/orders_state.dart';
import 'package:basketly/features/orders/presentation/widgets/order_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) => switch (state) {
            OrdersLoading() => const Center(child: CircularProgressIndicator()),
            OrdersError(:final message) => HomeErrorView(message: message, onRetry: cubit.load),
            OrdersLoaded(:final orders) => RefreshIndicator(
                onRefresh: cubit.load,
                child: ListView(
                  // Always scrollable, so pull-to-refresh works on a short list.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    BkSpace.xl, BkSpace.lg, BkSpace.xl, BkSpace.navClearance,
                  ),
                  children: [
                    const Text('Your orders', style: BkText.title),
                    const SizedBox(height: BkSpace.lg),
                    if (orders.isEmpty)
                      const _NoOrders()
                    else
                      for (final order in orders)
                        Padding(
                          padding: const EdgeInsets.only(bottom: BkSpace.md),
                          child: OrderTile(order: order, now: DateTime.now()),
                        ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }
}

class _NoOrders extends StatelessWidget {
  const _NoOrders();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(color: BkColors.soft, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_outlined, size: 44, color: BkColors.plum),
          ),
          const SizedBox(height: BkSpace.xl),
          const Text('No orders yet', style: BkText.heading),
          const SizedBox(height: BkSpace.sm),
          const Text('Your orders and their tracking show up here.', style: BkText.small),
          const SizedBox(height: BkSpace.xl),
          FilledButton(
            onPressed: () => context.go('/home'),
            style: FilledButton.styleFrom(
              backgroundColor: BkColors.plum,
              minimumSize: const Size(200, 52),
              shape: const StadiumBorder(),
            ),
            child: const Text('Start shopping'),
          ),
        ],
      ),
    );
  }
}
