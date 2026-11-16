import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/orders/data/orders_repository.dart';
import 'package:basketly/features/orders/presentation/cubit/tracking_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._repository, this._orderId) : super(const TrackingLoading());

  final OrdersRepository _repository;
  final String _orderId;

  Future<void> load() async {
    if (state is! TrackingLoaded) emit(const TrackingLoading());

    final result = await _repository.loadOrder(_orderId);
    if (isClosed) return;

    emit(switch (result) {
      Success(:final value) => TrackingLoaded(value),
      Failure(:final message) => TrackingError(message),
    });
  }
}
