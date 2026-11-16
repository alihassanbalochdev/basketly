import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.lineTotal,
    this.size,
    this.colour,
    this.departmentSlug,
  });

  final String name;
  final int price; // the price when ordered
  final int quantity;
  final int lineTotal;
  final String? size;
  final String? colour;
  final String? departmentSlug;

  /// "M, Plum" or "" when there are no options.
  String get optionsLabel => [?size, ?colour].join(', ');

  factory OrderItem.fromRow(Map<String, dynamic> row) {
    final product = row['products'];
    return OrderItem(
      name: row['name'] as String,
      price: row['price'] as int,
      quantity: row['quantity'] as int,
      lineTotal: row['line_total'] as int,
      size: row['size'] as String?,
      colour: row['colour'] as String?,
      departmentSlug: product is Map ? product['department_slug'] as String? : null,
    );
  }

  @override
  List<Object?> get props => [name, price, quantity, lineTotal, size, colour, departmentSlug];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.number,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.slotStart,
    required this.slotLabel,
    required this.createdAt,
    required this.addressLine,
    this.items = const [],
  });

  final String id;
  final String number; // BK-20001
  final String status; // placed, packed, on_the_way, delivered, cancelled
  final String paymentMethod; // cod or demo_card
  final int subtotal;
  final int discount;
  final int deliveryFee;
  final int total;
  final DateTime slotStart;
  final String slotLabel; // 'Today, 6 PM–8 PM' as written on the day
  final DateTime createdAt;
  final String addressLine;
  final List<OrderItem> items;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  int get departmentCount => {for (final item in items) item.departmentSlug}.length;

  /// Just the hours, '6 PM–8 PM', because "Today" goes stale.
  String get slotHours => slotLabel.split(', ').last;

  factory Order.fromRow(Map<String, dynamic> row) {
    final address = row['address'];
    final items = row['order_items'];
    return Order(
      id: row['id'] as String,
      number: row['number'] as String,
      status: row['status'] as String,
      paymentMethod: row['payment_method'] as String,
      subtotal: row['subtotal'] as int,
      discount: row['discount'] as int,
      deliveryFee: row['delivery_fee'] as int,
      total: row['total'] as int,
      slotStart: DateTime.parse(row['slot_start'] as String).toLocal(),
      slotLabel: row['slot_label'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      addressLine: address is Map ? '${address['line']}, ${address['city']}' : '',
      items: items is List
          ? [for (final item in items) OrderItem.fromRow(item as Map<String, dynamic>)]
          : const [],
    );
  }

  @override
  List<Object?> get props => [id, number, status, total, items];
}
