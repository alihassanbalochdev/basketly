import 'package:equatable/equatable.dart';

/// A colour option, like (name: 'Sand', hex: '#D8C29A').
typedef ProductColour = ({String name, String hex});

class Product extends Equatable {
  const Product({
    required this.id,
    required this.departmentSlug,
    required this.name,
    required this.subtitle,
    required this.price,
    this.wasPrice,
    this.imageUrl,
    this.isDeal = false,
    this.isStaple = false,
    this.sizes = const [],
    this.soldOutSizes = const [],
    this.colours = const [],
    this.departmentName,
    this.departmentTintHex,
  });

  final String id;
  final String departmentSlug;
  final String name;
  final String subtitle;
  final int price; // whole rupees
  final int? wasPrice; // set only when the product is discounted
  final String? imageUrl;
  final bool isDeal;
  final bool isStaple; // everyday items shown in "Buy it again"
  final List<String> sizes; // empty for products without sizes
  final List<String> soldOutSizes;
  final List<ProductColour> colours;
  // Joined from the departments table, so screens like the basket can
  // group and colour items without another query.
  final String? departmentName;
  final String? departmentTintHex;

  bool get needsSize => sizes.isNotEmpty;

  /// Products with options open their page; others can be added straight away.
  bool get canQuickAdd => sizes.isEmpty && colours.length <= 1;

  /// 3290 instead of 4100 -> 20. Null when there is no discount.
  int? get discountPercent {
    final was = wasPrice;
    if (was == null || was <= price) return null;
    return ((was - price) / was * 100).round();
  }

  int? get saving {
    final was = wasPrice;
    return (was == null || was <= price) ? null : was - price;
  }

  /// Reads a Supabase row. Also reads what [toJson] wrote, because both
  /// use the same keys — that's how the saved basket comes back.
  factory Product.fromRow(Map<String, dynamic> row) {
    List<String> strings(Object? value) =>
        value is List ? [for (final item in value) item as String] : const [];

    final department = row['departments'];

    return Product(
      id: row['id'] as String,
      departmentSlug: row['department_slug'] as String,
      name: row['name'] as String,
      subtitle: (row['subtitle'] as String?) ?? '',
      price: row['price'] as int,
      wasPrice: row['was_price'] as int?,
      imageUrl: row['image_url'] as String?,
      isDeal: (row['is_deal'] as bool?) ?? false,
      isStaple: (row['is_staple'] as bool?) ?? false,
      sizes: strings(row['sizes']),
      soldOutSizes: strings(row['sold_out_sizes']),
      colours: [
        if (row['colours'] case final List<dynamic> list)
          for (final item in list)
            if (item case {'name': final String name, 'hex': final String hex})
              (name: name, hex: hex),
      ],
      departmentName: department is Map ? department['name'] as String? : null,
      departmentTintHex: department is Map ? department['tint'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'department_slug': departmentSlug,
        'name': name,
        'subtitle': subtitle,
        'price': price,
        'was_price': wasPrice,
        'image_url': imageUrl,
        'is_deal': isDeal,
        'is_staple': isStaple,
        'sizes': sizes,
        'sold_out_sizes': soldOutSizes,
        'colours': [for (final c in colours) {'name': c.name, 'hex': c.hex}],
        'departments': {'name': departmentName, 'tint': departmentTintHex},
      };

  @override
  List<Object?> get props => [id, name, price, wasPrice, imageUrl];
}
