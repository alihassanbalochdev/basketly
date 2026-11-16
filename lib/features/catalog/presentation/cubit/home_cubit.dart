import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/catalog/data/catalog_repository.dart';
import 'package:basketly/features/catalog/presentation/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeLoading());

  final CatalogRepository _repository;

  Future<void> load() async {
    // Keep showing the old content during pull-to-refresh.
    if (state is! HomeLoaded) emit(const HomeLoading());

    final result = await _repository.loadHome();
    if (isClosed) return; // the screen was closed while we waited

    emit(switch (result) {
      Success(:final value) => HomeLoaded(value),
      Failure(:final message) => HomeError(message),
    });
  }
}
