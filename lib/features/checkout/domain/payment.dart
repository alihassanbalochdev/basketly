enum PaymentMethod {
  cashOnDelivery('cod', 'Cash on delivery'),
  demoCard('demo_card', 'Card (demo)');

  const PaymentMethod(this.code, this.label);

  final String code; // what the server stores
  final String label;
}

/// Checks for the demo card form. No card number ever leaves the phone:
/// only "demo_card" is sent to the server.
abstract final class CardRules {
  static String digits(String v) => v.replaceAll(RegExp(r'\D'), '');

  /// The Luhn check: the checksum every real card number passes.
  static bool luhn(String number) {
    final d = digits(number);
    if (d.length < 13 || d.length > 19) return false;
    var sum = 0;
    for (var i = 0; i < d.length; i++) {
      var n = int.parse(d[d.length - 1 - i]);
      if (i.isOdd) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
    }
    return sum % 10 == 0;
  }

  static String? number(String? v) => luhn(v ?? '') ? null : 'Check the card number';

  /// "MM/YY", not in the past.
  static String? expiry(String? v, {DateTime? now}) {
    final match = RegExp(r'^(\d{2})\s*/\s*(\d{2})$').firstMatch((v ?? '').trim());
    if (match == null) return 'Use MM/YY';
    final month = int.parse(match[1]!);
    final year = 2000 + int.parse(match[2]!);
    if (month < 1 || month > 12) return 'Use MM/YY';
    final today = now ?? DateTime.now();
    final endOfMonth = DateTime(year, month + 1);
    return endOfMonth.isAfter(today) ? null : 'This card has expired';
  }

  static String? cvc(String? v) =>
      RegExp(r'^\d{3,4}$').hasMatch((v ?? '').trim()) ? null : '3 or 4 digits';
}
