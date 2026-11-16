import 'dart:math' as math;

import 'package:basketly/features/basket/domain/basket_line.dart';

/// Delivery costs this much below [freeDeliveryThreshold].
const deliveryFeeRupees = 199;

int deliveryFeeFor(int subtotal) =>
    subtotal == 0 || subtotal >= freeDeliveryThreshold ? 0 : deliveryFeeRupees;

/// A promo code: what it says, and how much it takes off a subtotal.
typedef Promo = ({String code, String description, int Function(int subtotal) discount});

/// Demo codes. In a real shop these would come from the server.
final Map<String, Promo> _promos = {
  'BASKET10': (
    code: 'BASKET10',
    description: '10% off, up to Rs 500',
    discount: (subtotal) => math.min((subtotal * 0.10).round(), 500),
  ),
};

/// Case and spaces don't matter: " basket10 " finds BASKET10.
Promo? findPromo(String code) => _promos[code.trim().toUpperCase()];
