import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/features/catalog/presentation/widgets/home_error_view.dart';
import 'package:basketly/features/orders/domain/order_progress.dart';
import 'package:basketly/features/orders/presentation/cubit/tracking_cubit.dart';
import 'package:basketly/features/orders/presentation/cubit/tracking_state.dart';
import 'package:basketly/features/orders/presentation/widgets/order_items_card.dart';
import 'package:basketly/features/orders/presentation/widgets/rider_card.dart';
import 'package:basketly/features/orders/presentation/widgets/tracking_hero.dart';
import 'package:basketly/features/orders/presentation/widgets/tracking_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TrackingCubit>();
    void back() => context.canPop() ? context.pop() : context.go('/orders');

    return Scaffold(
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          switch (state) {
            case TrackingLoading():
              return const Center(child: CircularProgressIndicator());
            case TrackingError(:final message):
              return SafeArea(child: HomeErrorView(message: message, onRetry: cubit.load));
            case TrackingLoaded(:final order):
              // Worked out on every build, so pull-to-refresh moves it on.
              final now = DateTime.now();
              final stage = stageOf(order, now);

              return RefreshIndicator(
                onRefresh: cubit.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    TrackingHero(order: order, stage: stage, now: now, onBack: back),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(BkSpace.xl, 22, BkSpace.xl, BkSpace.xxl),
                      child: Column(
                        children: [
                          if (stage != OrderStage.cancelled)
                            TrackingTimeline(order: order, stage: stage, now: now),
                          if (stage == OrderStage.onTheWay) ...[
                            const SizedBox(height: BkSpace.lg),
                            const RiderCard(),
                          ],
                          const SizedBox(height: BkSpace.lg),
                          OrderItemsCard(order: order),
                        ],
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
