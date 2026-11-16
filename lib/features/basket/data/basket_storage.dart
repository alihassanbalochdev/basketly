import 'dart:convert';

import 'package:basketly/features/basket/domain/basket_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef SavedBasket = ({List<BasketLine> lines, String? promoCode});

/// Keeps the basket on the device, so closing the app doesn't empty it.
class BasketStorage {
  static const _key = 'basket_v1';

  Future<SavedBasket> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return (lines: <BasketLine>[], promoCode: null);

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        lines: [
          for (final item in json['lines'] as List<dynamic>)
            BasketLine.fromJson(item as Map<String, dynamic>),
        ],
        promoCode: json['promo'] as String?,
      );
    } on Object {
      // Saved by an older version, or damaged: start with an empty basket.
      return (lines: <BasketLine>[], promoCode: null);
    }
  }

  Future<void> save(List<BasketLine> lines, String? promoCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'lines': [for (final line in lines) line.toJson()],
        'promo': promoCode,
      }),
    );
  }
}
