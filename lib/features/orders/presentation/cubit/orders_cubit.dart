import 'dart:async';

import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/orders/data/orders_repository.dart';
import 'package:basketly/features/orders/presentation/cubit/orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lives for the whole app, so the list is ready when the tab opens.
/// It reloads by itself when someone signs in or out.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository) : super(const OrdersLoading()) {
    // Supabase sends the current session straight away, so this also
    // does the first load.
    _auth = _repository.authChanges.listen((_) => load());
  }

  final OrdersRepository _repository;
  late final StreamSubscription<Object> _auth;

  Future<void> load() async {
    if (!_repository.isSignedIn) {
      emit(const OrdersLoaded([]));
      return;
    }
    // Keep the old list on screen while refreshing.
    if (state is! OrdersLoaded) emit(const OrdersLoading());

    final result = await _repository.loadOrders();
    if (isClosed) return;

    emit(switch (result) {
      Success(:final value) => OrdersLoaded(value),
      Failure(:final message) => OrdersError(message),
    });
  }

  @override
  Future<void> close() {
    _auth.cancel();
    return super.close();
  }
}
