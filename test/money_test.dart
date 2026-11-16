import 'package:basketly/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats rupees with thousand separators', () {
    expect(rs(3290), 'Rs 3,290');
    expect(rs(990), 'Rs 990');
    expect(rs(12499), 'Rs 12,499');
  });
}
