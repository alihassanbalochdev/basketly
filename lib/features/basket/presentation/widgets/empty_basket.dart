import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyBasket extends StatelessWidget {
  const EmptyBasket({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BkSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(color: BkColors.plum, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const BasketIcon(fill: 0, size: 54),
            ),
            const SizedBox(height: BkSpace.xl),
            const Text('Your basket is empty', style: BkText.heading),
            const SizedBox(height: BkSpace.sm),
            const Text(
              'Add something and watch it fill up.',
              textAlign: TextAlign.center,
              style: BkText.small,
            ),
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
      ),
    );
  }
}
