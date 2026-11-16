import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/utils/money.dart';
import 'package:basketly/core/widgets/round_icon_button.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/checkout/domain/payment.dart';
import 'package:basketly/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:basketly/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:basketly/features/checkout/presentation/widgets/address_section.dart';
import 'package:basketly/features/checkout/presentation/widgets/checkout_steps.dart';
import 'package:basketly/features/checkout/presentation/widgets/payment_section.dart';
import 'package:basketly/features/checkout/presentation/widgets/slot_picker.dart';
import 'package:basketly/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // The demo card form lives here so "Place order" can check it.
  final _cardForm = GlobalKey<FormState>();

  void _place(CheckoutState checkout) {
    if (checkout.payment == PaymentMethod.demoCard &&
        !(_cardForm.currentState?.validate() ?? false)) {
      return;
    }
    context.read<CheckoutCubit>().placeOrder(context.read<BasketCubit>().state);
  }

  @override
  Widget build(BuildContext context) {
    final total = context.select<BasketCubit, int>((cubit) => cubit.state.total);

    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listenWhen: (before, now) => before.status != now.status,
      listener: (context, checkout) {
        if (checkout.placedOrder case final order? when checkout.status == CheckoutStatus.placed) {
          context.read<BasketCubit>().clear();
          context.read<OrdersCubit>().load(); // the new order joins the list
          // `go`, not `push`: Back must not return to a finished checkout.
          context.go('/order-placed', extra: order);
        }
      },
      builder: (context, checkout) {
        if (checkout.status == CheckoutStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final placing = checkout.status == CheckoutStatus.placing;
        final canPlace = !placing && !checkout.showAddressForm && checkout.slot != null;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.lg, BkSpace.xl, BkSpace.xl),
                    children: [
                      Row(
                        children: [
                          RoundIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Back to basket',
                            onPressed: () => context.canPop() ? context.pop() : context.go('/basket'),
                          ),
                          const SizedBox(width: 14),
                          const Text('Checkout', style: BkText.title),
                        ],
                      ),
                      const SizedBox(height: BkSpace.lg),
                      CheckoutSteps(
                        addressDone: !checkout.showAddressForm,
                        slotDone: checkout.slot != null,
                      ),
                      const SizedBox(height: BkSpace.xl),
                      AddressSection(checkout: checkout),
                      const SizedBox(height: BkSpace.xl),
                      const Text('Delivery time', style: BkText.heading),
                      const SizedBox(height: BkSpace.md),
                      SlotPicker(
                        slots: checkout.slots,
                        selected: checkout.slotIndex,
                        onSelected: context.read<CheckoutCubit>().selectSlot,
                      ),
                      const SizedBox(height: BkSpace.xl),
                      const Text('Payment', style: BkText.heading),
                      const SizedBox(height: BkSpace.md),
                      PaymentSection(
                        selected: checkout.payment,
                        onSelected: context.read<CheckoutCubit>().selectPayment,
                        cardFormKey: _cardForm,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.sm, BkSpace.xl, BkSpace.lg),
                  child: Column(
                    children: [
                      if (checkout.error case final error?)
                        Padding(
                          padding: const EdgeInsets.only(bottom: BkSpace.sm),
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
                            style: BkText.small.copyWith(color: const Color(0xFFB3261E)),
                          ),
                        ),
                      FilledButton(
                        onPressed: canPlace ? () => _place(checkout) : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: BkColors.plum,
                          disabledBackgroundColor: BkColors.soft,
                          minimumSize: const Size.fromHeight(56),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: placing
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : Text(
                                checkout.payment == PaymentMethod.demoCard
                                    ? 'Pay ${rs(total)}'
                                    : 'Place order · ${rs(total)}',
                              ),
                      ),
                      if (checkout.payment == PaymentMethod.demoCard)
                        const Padding(
                          padding: EdgeInsets.only(top: BkSpace.sm),
                          child: Text('Demo payment. No money is charged.', style: BkText.tiny),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
