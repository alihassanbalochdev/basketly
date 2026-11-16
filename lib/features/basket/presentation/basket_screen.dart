import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/widgets/round_icon_button.dart';
import 'package:basketly/features/basket/domain/basket_line.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_state.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_line_tile.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_summary.dart';
import 'package:basketly/features/basket/presentation/widgets/empty_basket.dart';
import 'package:basketly/features/basket/presentation/widgets/free_delivery_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<BasketCubit, BasketState>(
          builder: (context, basket) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.lg, BkSpace.xl, 0),
                  child: Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(child: Text('Your basket', style: BkText.title)),
                      if (!basket.isEmpty)
                        Text(
                          basket.itemCount == 1 ? '1 item' : '${basket.itemCount} items',
                          style: BkText.small,
                        ),
                    ],
                  ),
                ),
                if (basket.isEmpty)
                  const Expanded(child: EmptyBasket())
                else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.lg, BkSpace.xl, 0),
                    child: FreeDeliveryCard(
                      progress: basket.freeDeliveryProgress,
                      amountLeft: basket.amountToFreeDelivery,
                    ),
                  ),
                  Expanded(child: _GroupedLines(lines: basket.lines.values.toList())),
                  const BasketSummary(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Lines under a small department heading, in the order first added.
class _GroupedLines extends StatelessWidget {
  const _GroupedLines({required this.lines});

  final List<BasketLine> lines;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<BasketLine>>{};
    for (final line in lines) {
      groups.putIfAbsent(line.product.departmentName ?? 'Other', () => []).add(line);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.sm, BkSpace.xl, BkSpace.lg),
      children: [
        for (final MapEntry(key: name, value: groupLines) in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
            child: Text(name, style: BkText.label.copyWith(color: BkText.small.color)),
          ),
          for (final line in groupLines)
            Padding(
              padding: const EdgeInsets.only(top: BkSpace.sm),
              child: BasketLineTile(line: line),
            ),
        ],
      ],
    );
  }
}
