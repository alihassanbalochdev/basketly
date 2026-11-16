import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/orders/domain/order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersRepository {
  OrdersRepository(this._db);

  final SupabaseClient _db;

  // Each item also brings its product's department, for icons.
  static const _columns = '*, order_items(*, products(department_slug))';

  bool get isSignedIn => _db.auth.currentUser != null;

  /// Fires when someone signs in or out.
  Stream<AuthState> get authChanges => _db.auth.onAuthStateChange;

  /// Newest first. Row Level Security returns only this person's orders.
  Future<Result<List<Order>>> loadOrders() => _guard(() async {
        final rows = await _db.from('orders').select(_columns).order('created_at', ascending: false);
        return [for (final row in rows) Order.fromRow(row)];
      });

  Future<Result<Order>> loadOrder(String id) => _guard(() async {
        final row = await _db.from('orders').select(_columns).eq('id', id).maybeSingle();
        if (row == null) throw const _NotFound();
        return Order.fromRow(row);
      });

  Future<Result<T>> _guard<T>(Future<T> Function() load) async {
    try {
      return Success(await load());
    } on _NotFound catch (error) {
      return Failure("We couldn't find that order.", cause: error);
    } on Object catch (error) {
      return Failure(
        "Couldn't load your orders. Check your connection and try again.",
        cause: error,
      );
    }
  }
}

class _NotFound implements Exception {
  const _NotFound();
}
