import 'package:equatable/equatable.dart';

class Department extends Equatable {
  const Department({
    required this.slug,
    required this.name,
    required this.itemCount,
    required this.tintHex,
    this.imageUrl,
  });

  final String slug; // 'groceries', 'fashion', ...
  final String name;
  final int itemCount;
  final String tintHex; // '#E5EEDC', turned into a Color in the UI layer
  final String? imageUrl; // illustration from Supabase Storage

  factory Department.fromRow(Map<String, dynamic> row) {
    return Department(
      slug: row['slug'] as String,
      name: row['name'] as String,
      itemCount: row['item_count'] as int,
      tintHex: row['tint'] as String,
      imageUrl: row['image_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [slug, name, itemCount, tintHex, imageUrl];
}
