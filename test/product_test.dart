import 'package:basketly/features/catalog/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Product make({required int price, int? was}) => Product(
        id: '1', departmentSlug: 'fashion', name: 'Linen kurta',
        subtitle: '', price: price, wasPrice: was,
      );

  test('discount is rounded to a whole percent', () {
    expect(make(price: 3290, was: 4100).discountPercent, 20);
    expect(make(price: 5499, was: 8999).discountPercent, 39);
    expect(make(price: 3290, was: 4100).saving, 810);
  });

  test('no discount without a higher old price', () {
    expect(make(price: 990).discountPercent, isNull);
    expect(make(price: 990, was: 990).discountPercent, isNull);
  });

  test('reads sizes and colours from a Supabase row', () {
    final p = Product.fromRow({
      'id': 'abc', 'department_slug': 'fashion', 'name': 'Linen kurta',
      'subtitle': null, 'price': 3290, 'was_price': 4100,
      'image_url': null, 'is_deal': false, 'is_staple': false,
      'sizes': ['S', 'M', 'XXL'], 'sold_out_sizes': ['XXL'],
      'colours': [
        {'name': 'Sand', 'hex': '#D8C29A'},
        {'broken': true}, // malformed entries are skipped
      ],
    });

    expect(p.subtitle, '');
    expect(p.sizes, ['S', 'M', 'XXL']);
    expect(p.soldOutSizes, ['XXL']);
    expect(p.colours.single.name, 'Sand');
    expect(p.needsSize, isTrue);
    expect(p.canQuickAdd, isFalse);
  });

  test('products without options can be added from the grid', () {
    expect(make(price: 290).canQuickAdd, isTrue);
  });
}
