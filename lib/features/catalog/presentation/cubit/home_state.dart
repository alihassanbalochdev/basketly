import 'package:basketly/features/catalog/domain/home_data.dart';
import 'package:equatable/equatable.dart';

/// Sealed: the Home screen must handle all three cases in its switch.
sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.data);

  final HomeData data;

  @override
  List<Object?> get props => [data];
}

final class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
