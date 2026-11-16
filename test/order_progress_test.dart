import 'package:basketly/features/orders/domain/order.dart';
import 'package:basketly/features/orders/domain/order_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Ordered at 5 PM for the 8 PM–10 PM slot.
  Order order({String status = 'placed'}) => Order(
        id: '1', number: 'BK-20001', status: status, paymentMethod: 'cod',
        subtotal: 1000, discount: 0, deliveryFee: 199, total: 1199,
        slotStart: DateTime(2026, 11, 15, 20), slotLabel: 'Today, 8 PM–10 PM',
        createdAt: DateTime(2026, 11, 15, 17), addressLine: '',
      );

  test('the stage moves on with the clock', () {
    expect(stageOf(order(), DateTime(2026, 11, 15, 17, 5)), OrderStage.placed);
    expect(stageOf(order(), DateTime(2026, 11, 15, 17, 30)), OrderStage.packed);
    expect(stageOf(order(), DateTime(2026, 11, 15, 20, 15)), OrderStage.onTheWay);
    expect(stageOf(order(), DateTime(2026, 11, 15, 21, 0)), OrderStage.delivered);
  });

  test('a status set by hand wins when it is further along', () {
    final early = DateTime(2026, 11, 15, 17, 1);
    expect(stageOf(order(status: 'on_the_way'), early), OrderStage.onTheWay);
    expect(stageOf(order(status: 'cancelled'), DateTime(2026, 11, 15, 21)), OrderStage.cancelled);
  });

  test('slot hours drop the stale day word', () {
    expect(order().slotHours, '8 PM–10 PM');
    expect(dayWord(DateTime(2026, 11, 16, 10), DateTime(2026, 11, 15, 23)), 'tomorrow');
    expect(clockTime(DateTime(2026, 11, 15, 17, 42)), '5:42 PM');
  });
}
