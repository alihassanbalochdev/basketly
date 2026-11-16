import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/catalog/domain/browse_sort.dart';
import 'package:basketly/features/catalog/domain/catalog_data.dart';
import 'package:basketly/features/catalog/domain/department.dart';
import 'package:basketly/features/catalog/domain/home_data.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatalogRepository {
  CatalogRepository(this._db);

  final SupabaseClient _db;

  /// Every product query also brings its department's name and colour.
  static const _productColumns = '*, departments(name, tint)';

  /// image_url holds a file name like 'kettle.png' from the 'products'
  /// Storage bucket. This swaps it for the full public link.
  Map<String, dynamic> _withPublicUrl(Map<String, dynamic> row) {
    final file = row['image_url'];
    if (file is String && file.isNotEmpty && !file.startsWith('http')) {
      return {...row, 'image_url': _db.storage.from('products').getPublicUrl(file)};
    }
    return row;
  }

  Product _product(Map<String, dynamic> row) => Product.fromRow(_withPublicUrl(row));

  Department _department(Map<String, dynamic> row) => Department.fromRow(_withPublicUrl(row));

  Future<Result<HomeData>> loadHome() {
    return _guard(() async {
      // Three queries in parallel. A record of futures + `.wait`
      // waits for all of them and keeps each result's own type.
      final (departmentRows, dealRows, stapleRows) = await (
        _db.from('departments').select().order('position'),
        _db.from('products').select(_productColumns).eq('is_deal', true).limit(1),
        _db.from('products').select(_productColumns).eq('is_staple', true).order('name'),
      ).wait;

      return (
        departments: [for (final row in departmentRows) _department(row)],
        deal: dealRows.isEmpty ? null : _product(dealRows.first),
        buyAgain: [for (final row in stapleRows) _product(row)],
      );
    });
  }

  /// [department] null means every department.
  Future<Result<BrowseData>> loadBrowse({
    String? department,
    BrowseSort sort = BrowseSort.popular,
  }) {
    return _guard(() async {
      var products = _db.from('products').select(_productColumns);
      if (department != null) products = products.eq('department_slug', department);

      final (departmentRows, productRows) = await (
        _db.from('departments').select().order('position'),
        products.order(sort.column, ascending: sort.ascending),
      ).wait;

      return (
        departments: [for (final row in departmentRows) _department(row)],
        products: [for (final row in productRows) _product(row)],
      );
    });
  }

  Future<Result<ProductDetail>> loadProduct(String id) {
    return _guard(() async {
      // `departments(*)` follows the foreign key and nests the department row.
      final row = await _db
          .from('products')
          .select('*, departments(*)')
          .eq('id', id)
          .single();

      return (
        product: _product(row),
        department: _department(row['departments'] as Map<String, dynamic>),
      );
    });
  }

  /// Products whose name or description contains [query].
  Future<Result<List<Product>>> search(String query) {
    return _guard(() async {
      // Commas, brackets and quotes have a meaning inside `or(...)`,
      // so they are taken out of what the person typed.
      final words = query.replaceAll(RegExp(r'[,()"*%\\]'), ' ').trim();
      if (words.isEmpty) return const <Product>[];

      final rows = await _db
          .from('products')
          .select(_productColumns)
          .or('name.ilike."%$words%",subtitle.ilike."%$words%"')
          .order('popularity', ascending: false)
          .limit(30);
      return [for (final row in rows) _product(row)];
    });
  }

  /// One place that turns exceptions into Failure, for every query.
  Future<Result<T>> _guard<T>(Future<T> Function() query) async {
    try {
      return Success(await query());
    } on PostgrestException catch (error) {
      return Failure(error.message, cause: error);
    } on Object catch (error) {
      return Failure(
        "Couldn't reach Basketly. Check your connection and try again.",
        cause: error,
      );
    }
  }
}
