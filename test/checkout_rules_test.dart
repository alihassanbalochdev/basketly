import 'package:basketly/features/checkout/domain/delivery_address.dart';
import 'package:basketly/features/checkout/domain/delivery_slot.dart';
import 'package:basketly/features/checkout/domain/payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('delivery slots', () {
    test('today skips slots that start within 90 minutes', () {
      final slots = deliverySlots(DateTime(2026, 11, 15, 17, 0)); // 5 PM
      expect(slots.first.label, 'Today, 8 PM–10 PM'); // 6 PM is too soon
      expect(slots.first.start, DateTime(2026, 11, 15, 20));
    });

    test('late at night the first slot is tomorrow morning', () {
      final slots = deliverySlots(DateTime(2026, 11, 15, 22, 30));
      expect(slots.first.label, 'Tomorrow, 10 AM–12 PM');
      expect(slots.length, 6);
    });
  });

  group('demo card checks', () {
    test('the classic test card passes, a typo fails', () {
      expect(CardRules.number('4242 4242 4242 4242'), isNull);
      expect(CardRules.number('4242 4242 4242 4241'), isNotNull);
    });

    test('expiry must be MM/YY and not in the past', () {
      final now = DateTime(2026, 11, 15);
      expect(CardRules.expiry('11/26', now: now), isNull); // valid all month
      expect(CardRules.expiry('10/26', now: now), 'This card has expired');
      expect(CardRules.expiry('13/27', now: now), 'Use MM/YY');
      expect(CardRules.expiry('1127', now: now), 'Use MM/YY');
    });

    test('CVC is 3 or 4 digits', () {
      expect(CardRules.cvc('123'), isNull);
      expect(CardRules.cvc('12'), isNotNull);
    });
  });

  test('address rules match what the server checks', () {
    expect(AddressRules.phone('0300 1234567'), isNull);
    expect(AddressRules.phone('12345'), isNotNull);
    expect(AddressRules.line('House 24, DHA'), isNull);
    expect(AddressRules.line('H1'), isNotNull);
  });
}
