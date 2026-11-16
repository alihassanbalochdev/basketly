import 'package:basketly/features/checkout/domain/delivery_address.dart';
import 'package:basketly/features/checkout/domain/delivery_slot.dart';
import 'package:basketly/features/checkout/domain/payment.dart';
import 'package:basketly/features/checkout/domain/placed_order.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum CheckoutStatus { loading, ready, placing, placed }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.loading,
    this.address,
    this.editingAddress = false,
    this.slots = const [],
    this.slotIndex = 0,
    this.payment = PaymentMethod.cashOnDelivery,
    this.error,
    this.placedOrder,
  });

  final CheckoutStatus status;
  final DeliveryAddress? address;
  final bool editingAddress;
  final List<DeliverySlot> slots;
  final int slotIndex;
  final PaymentMethod payment;
  final String? error;
  final PlacedOrder? placedOrder;

  DeliverySlot? get slot => slots.isEmpty ? null : slots[slotIndex];

  bool get showAddressForm => address == null || editingAddress;

  CheckoutState copyWith({
    CheckoutStatus? status,
    ValueGetter<DeliveryAddress?>? address,
    bool? editingAddress,
    List<DeliverySlot>? slots,
    int? slotIndex,
    PaymentMethod? payment,
    ValueGetter<String?>? error,
    PlacedOrder? placedOrder,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      address: address != null ? address() : this.address,
      editingAddress: editingAddress ?? this.editingAddress,
      slots: slots ?? this.slots,
      slotIndex: slotIndex ?? this.slotIndex,
      payment: payment ?? this.payment,
      error: error != null ? error() : this.error,
      placedOrder: placedOrder ?? this.placedOrder,
    );
  }

  @override
  List<Object?> get props =>
      [status, address, editingAddress, slots, slotIndex, payment, error, placedOrder];
}
