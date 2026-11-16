import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_state.dart';
import 'package:basketly/features/checkout/data/checkout_repository.dart';
import 'package:basketly/features/checkout/domain/delivery_address.dart';
import 'package:basketly/features/checkout/domain/delivery_slot.dart';
import 'package:basketly/features/checkout/domain/payment.dart';
import 'package:basketly/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._repository) : super(const CheckoutState());

  final CheckoutRepository _repository;

  Future<void> load() async {
    final address = await _repository.loadAddress();
    if (isClosed) return;
    emit(state.copyWith(
      status: CheckoutStatus.ready,
      address: () => address,
      slots: deliverySlots(DateTime.now()),
    ));
  }

  void useAddress(DeliveryAddress address) =>
      emit(state.copyWith(address: () => address, editingAddress: false));

  void editAddress() => emit(state.copyWith(editingAddress: true));

  void selectSlot(int index) => emit(state.copyWith(slotIndex: index));

  void selectPayment(PaymentMethod payment) => emit(state.copyWith(payment: payment));

  Future<void> placeOrder(BasketState basket) async {
    final address = state.address;
    final slot = state.slot;
    if (address == null || slot == null || state.status == CheckoutStatus.placing) return;

    emit(state.copyWith(status: CheckoutStatus.placing, error: () => null));

    final result = await _repository.placeOrder(
      basket: basket,
      address: address,
      slot: slot,
      payment: state.payment,
    );
    if (isClosed) return;

    emit(switch (result) {
      Success(:final value) => state.copyWith(status: CheckoutStatus.placed, placedOrder: value),
      Failure(:final message) => state.copyWith(status: CheckoutStatus.ready, error: () => message),
    });
  }
}
