import 'package:basketly/features/orders/domain/order.dart';
import 'package:equatable/equatable.dart';

sealed class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

final class TrackingLoading extends TrackingState {
  const TrackingLoading();
}

final class TrackingLoaded extends TrackingState {
  const TrackingLoaded(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

final class TrackingError extends TrackingState {
  const TrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
