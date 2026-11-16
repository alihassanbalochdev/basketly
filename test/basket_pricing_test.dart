import 'package:basketly/features/basket/domain/basket_line.dart';
import 'package:basketly/features/basket/domain/basket_pricing.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const milk = Product(
    id: 'milk', departmentSlug: 'groceries', name: 'Fresh milk', subtitle: '', price: 290,
  );
  const watch = Product(
    id: 'watch', departmentSlug: 'electronics', name: 'Smart watch', subtitle: '', price: 9999,
  );

  test('delivery is charged under the threshold and free above it', () {
    expect(deliveryFeeFor(0), 0); // empty basket: nothing to deliver
    expect(deliveryFeeFor(290), deliveryFeeRupees);
    expect(deliveryFeeFor(freeDeliveryThreshold), 0);
  });

  test('promo codes ignore case and spaces; unknown codes are rejected', () {
    expect(findPromo(' basket10 ')?.code, 'BASKET10');
    expect(findPromo('NOPE'), isNull);
  });

  test('BASKET10 takes 10% off, capped at Rs 500', () {
    final small = BasketCubit()
      ..add(milk, quantity: 10) // Rs 2,900
      ..applyPromo('basket10');
    expect(small.state.discount, 290);
    expect(small.state.total, 2900 - 290); // free delivery: subtotal >= 2,500

    final big = BasketCubit()
      ..add(watch)
      ..applyPromo('BASKET10');
    expect(big.state.discount, 500);
  });

  test('a small basket pays delivery and says how much is left', () {
    final basket = BasketCubit()..add(milk);
    expect(basket.state.deliveryFee, deliveryFeeRupees);
    expect(basket.state.total, 290 + deliveryFeeRupees);
    expect(basket.state.amountToFreeDelivery, freeDeliveryThreshold - 290);
  });

  test('remove returns the line so Undo can put it back', () {
    final basket = BasketCubit()..add(milk, quantity: 3);
    final removed = basket.remove(lineKey('milk'));
    expect(basket.state.isEmpty, isTrue);

    basket.restoreLine(removed!);
    expect(basket.state.itemCount, 3);
  });

  test('a saved line comes back identical', () {
    const kurta = Product(
      id: 'k', departmentSlug: 'fashion', name: 'Linen kurta', subtitle: 'Men, sand',
      price: 3290, wasPrice: 4100, sizes: ['M', 'L'],
      colours: [(name: 'Sand', hex: '#D8C29A')],
      departmentName: 'Fashion', departmentTintHex: '#F3E2E8',
    );
    const line = BasketLine(product: kurta, quantity: 2, size: 'M', colour: 'Sand');

    final back = BasketLine.fromJson(line.toJson());
    expect(back, line);
    expect(back.product.departmentName, 'Fashion');
    expect(back.product.colours.single.hex, '#D8C29A');
  });
}
