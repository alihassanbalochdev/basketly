import 'package:basketly/features/catalog/domain/product.dart';
import 'package:equatable/equatable.dart';

/// Orders over this amount get free delivery.
const freeDeliveryThreshold = 2500;

class BasketLine extends Equatable {
  const BasketLine({
    required this.product,
    required this.quantity,
    this.size,
    this.colour,
  });

  final Product product;
  final int quantity;
  final String? size;
  final String? colour;

  /// A kurta in M and the same kurta in L are two different lines.
  String get key => lineKey(product.id, size: size, colour: colour);

  int get total => product.price * quantity;

  /// "Sand, size M", or '' for products without options.
  String get optionsLabel => [
        ?colour,
        if (size != null) 'size $size',
      ].join(', ');

  BasketLine copyWith({int? quantity}) => BasketLine(
        product: product,
        quantity: quantity ?? this.quantity,
        size: size,
        colour: colour,
      );

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'size': size,
        'colour': colour,
      };

  factory BasketLine.fromJson(Map<String, dynamic> json) => BasketLine(
        product: Product.fromRow(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
        size: json['size'] as String?,
        colour: json['colour'] as String?,
      );

  @override
  List<Object?> get props => [product, quantity, size, colour];
}

String lineKey(String productId, {String? size, String? colour}) =>
    '$productId|${size ?? ''}|${colour ?? ''}';
