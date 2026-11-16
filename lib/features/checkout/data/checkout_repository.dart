import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_state.dart';
import 'package:basketly/features/checkout/domain/delivery_address.dart';
import 'package:basketly/features/checkout/domain/delivery_slot.dart';
import 'package:basketly/features/checkout/domain/payment.dart';
import 'package:basketly/features/checkout/domain/placed_order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutRepository {
  CheckoutRepository(this._db);

  final SupabaseClient _db;

  /// The address used last time, or null for a first order.
  Future<DeliveryAddress?> loadAddress() async {
    try {
      final row = await _db.from('addresses').select().maybeSingle();
      return row == null ? null : DeliveryAddress.fromRow(row);
    } on Object {
      return null; // not fatal: the form simply starts empty
    }
  }

  Future<Result<PlacedOrder>> placeOrder({
    required BasketState basket,
    required DeliveryAddress address,
    required DeliverySlot slot,
    required PaymentMethod payment,
  }) async {
    try {
      // Remember the address for next time. Row Level Security only lets
      // a person write their own row.
      await _db.from('addresses').upsert({
        'user_id': _db.auth.currentUser!.id,
        ...address.toRow(),
      });

      // Only ids, quantities and options go to the server — never prices.
      final response = await _db.functions.invoke('place-order', body: {
        'items': [
          for (final line in basket.lines.values)
            {
              'product_id': line.product.id,
              'quantity': line.quantity,
              'size': line.size,
              'colour': line.colour,
            },
        ],
        'promo_code': basket.promoCode,
        'payment_method': payment.code,
        'address': address.toRow(),
        'slot_start': slot.start.toUtc().toIso8601String(),
        'slot_label': slot.label,
      });

      return Success(placedOrderFromJson(response.data as Map<String, dynamic>));
    } on FunctionException catch (error) {
      // The function sends {"error": "..."} with a message for people.
      final details = error.details;
      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : "Couldn't place your order. Try again.";
      return Failure(message, cause: error);
    } on PostgrestException catch (error) {
      return Failure(error.message, cause: error);
    } on Object catch (error) {
      return Failure(
        "Couldn't reach Basketly. Check your connection and try again.",
        cause: error,
      );
    }
  }
}
