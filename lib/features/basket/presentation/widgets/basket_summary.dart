import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/utils/money.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The white sheet at the bottom: promo code, totals, checkout.
class BasketSummary extends StatefulWidget {
  const BasketSummary({super.key});

  @override
  State<BasketSummary> createState() => _BasketSummaryState();
}

class _BasketSummaryState extends State<BasketSummary> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _apply() {
    final ok = context.read<BasketCubit>().applyPromo(_code.text);
    setState(() => _error = ok ? null : "That code doesn't exist. Check the spelling.");
    if (ok) {
      _code.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final basket = context.watch<BasketCubit>().state;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(BkSpace.xl, 18, BkSpace.xl, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: BkColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Color(0x143D1440), blurRadius: 24, offset: Offset(0, -8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (basket.promo case final promo?)
            _AppliedPromo(
              code: promo.code,
              description: promo.description,
              onRemove: context.read<BasketCubit>().clearPromo,
            )
          else
            _PromoField(controller: _code, error: _error, onApply: _apply),
          const SizedBox(height: BkSpace.md),
          _Row(label: 'Subtotal', value: rs(basket.subtotal)),
          if (basket.discount > 0) _Row(label: 'Promo', value: '−${rs(basket.discount)}'),
          _Row(label: 'Delivery', value: basket.deliveryFee == 0 ? 'Free' : rs(basket.deliveryFee)),
          const SizedBox(height: 4),
          _Row(label: 'Total', value: rs(basket.total), strong: true),
          const SizedBox(height: BkSpace.md),
          FilledButton(
            onPressed: () => context.push('/checkout'),
            style: FilledButton.styleFrom(
              backgroundColor: BkColors.plum,
              minimumSize: const Size.fromHeight(56),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            child: const Text('Go to checkout'),
          ),
        ],
      ),
    );
  }
}

class _PromoField extends StatelessWidget {
  const _PromoField({required this.controller, required this.error, required this.onApply});

  final TextEditingController controller;
  final String? error;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => onApply(),
                decoration: InputDecoration(
                  hintText: 'Promo code',
                  hintStyle: BkText.small,
                  filled: true,
                  fillColor: BkColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(23),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: BkSpace.sm),
            TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                backgroundColor: BkColors.soft,
                foregroundColor: BkColors.plum,
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 0, 0),
            child: Text(error!, style: BkText.tiny.copyWith(color: const Color(0xFFB3261E))),
          ),
      ],
    );
  }
}

class _AppliedPromo extends StatelessWidget {
  const _AppliedPromo({required this.code, required this.description, required this.onRemove});

  final String code;
  final String description;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      decoration: BoxDecoration(color: BkColors.soft, borderRadius: BorderRadius.circular(23)),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, size: 18, color: BkColors.plum),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '$code  ', style: BkText.label.copyWith(color: BkColors.plum)),
              TextSpan(text: description, style: BkText.tiny),
            ])),
          ),
          IconButton(
            tooltip: 'Remove promo code',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18, color: BkColors.plum),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: BkColors.ink)
        : BkText.small.copyWith(fontSize: 14);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style.copyWith(color: BkColors.ink)),
        ],
      ),
    );
  }
}
