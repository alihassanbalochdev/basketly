import 'package:basketly/features/basket/domain/basket_line.dart';
import 'package:basketly/features/basket/domain/basket_pricing.dart';
import 'package:equatable/equatable.dart';

class BasketState extends Equatable {
  const BasketState({this.lines = const {}, this.promoCode});

  /// Keyed by [BasketLine.key]: product + size + colour.
  final Map<String, BasketLine> lines;
  final String? promoCode;

  bool get isEmpty => lines.isEmpty;

  int get itemCount => lines.values.fold(0, (sum, line) => sum + line.quantity);

  int get subtotal => lines.values.fold(0, (sum, line) => sum + line.total);

  Promo? get promo => promoCode == null ? null : findPromo(promoCode!);

  int get discount => promo?.discount(subtotal) ?? 0;

  int get deliveryFee => deliveryFeeFor(subtotal);

  int get total => subtotal - discount + deliveryFee;

  /// How much more to spend before delivery is free (0 once it is).
  int get amountToFreeDelivery =>
      subtotal >= freeDeliveryThreshold ? 0 : freeDeliveryThreshold - subtotal;

  /// 0.0 to 1.0: how close the basket is to free delivery.
  /// This is what fills the basket icon with saffron.
  double get freeDeliveryProgress =>
      (subtotal / freeDeliveryThreshold).clamp(0.0, 1.0);

  /// True if any size or colour of this product is in the basket.
  bool contains(String productId) =>
      lines.values.any((line) => line.product.id == productId);

  BasketState copyWith({Map<String, BasketLine>? lines, String? Function()? promoCode}) {
    return BasketState(
      lines: lines ?? this.lines,
      promoCode: promoCode != null ? promoCode() : this.promoCode,
    );
  }

  @override
  List<Object?> get props => [lines, promoCode];
}
