import 'package:basketly/core/router/floating_nav_bar.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_state.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_button.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_targets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Wraps the four tabs and floats the nav bar on top of them.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          shell,
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: FloatingNavBar(
              currentIndex: shell.currentIndex,
              onSelect: (index) => shell.goBranch(
                index,
                // Tapping the tab you're on scrolls back to its first page.
                initialLocation: index == shell.currentIndex,
              ),
              // The key lets products fly into this exact spot.
              basket: KeyedSubtree(
                key: navBasketKey,
                // Only this small part rebuilds when the basket changes.
                child: BlocBuilder<BasketCubit, BasketState>(
                  builder: (context, basket) => BasketButton(
                    count: basket.itemCount,
                    fill: basket.freeDeliveryProgress,
                    onTap: () => context.push('/basket'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
