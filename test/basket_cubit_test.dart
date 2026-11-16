import 'package:basketly/features/basket/domain/basket_line.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const milk = Product(
    id: 'milk', departmentSlug: 'groceries', name: 'Fresh milk', subtitle: '', price: 290,
  );
  const kurta = Product(
    id: 'kurta', departmentSlug: 'fashion', name: 'Linen kurta', subtitle: '', price: 3290,
  );

  test('adding the same product twice merges into one line', () {
    final basket = BasketCubit()
      ..add(milk)
      ..add(milk, quantity: 2);

    expect(basket.state.lines.length, 1);
    expect(basket.state.itemCount, 3);
    expect(basket.state.subtotal, 870);
  });

  test('different sizes of one product are separate lines', () {
    final basket = BasketCubit()
      ..add(kurta, size: 'M', colour: 'Sand')
      ..add(kurta, size: 'L', colour: 'Sand');

    expect(basket.state.lines.length, 2);
    expect(basket.state.contains('kurta'), isTrue);
    expect(basket.state.lines.values.first.optionsLabel, 'Sand, size M');
  });

  test('the basket fills towards free delivery and stops at full', () {
    final basket = BasketCubit()..add(milk);
    expect(basket.state.freeDeliveryProgress, closeTo(290 / 2500, 0.0001));

    basket.add(kurta, size: 'M');
    expect(basket.state.freeDeliveryProgress, 1.0);
  });

  test('quantity zero removes the line', () {
    final basket = BasketCubit()
      ..add(milk)
      ..setQuantity(lineKey('milk'), 0);

    expect(basket.state.contains('milk'), isFalse);
    expect(basket.state.itemCount, 0);
  });
}
