import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/catalog/data/catalog_repository.dart';
import 'package:basketly/features/catalog/domain/browse_sort.dart';
import 'package:basketly/features/catalog/presentation/cubit/browse_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowseCubit extends Cubit<BrowseState> {
  BrowseCubit(this._repository, {String? department})
      : super(BrowseState(department: department));

  final CatalogRepository _repository;
  int _request = 0;

  Future<void> load() async {
    // Tap two chips quickly and two requests race. Only the newest
    // one may update the screen, whichever finishes first.
    final request = ++_request;
    emit(state.copyWith(status: BrowseStatus.loading));

    final result = await _repository.loadBrowse(
      department: state.department,
      sort: state.sort,
    );
    if (isClosed || request != _request) return;

    emit(switch (result) {
      Success(:final value) => state.copyWith(
          status: BrowseStatus.ready,
          departments: value.departments,
          products: value.products,
        ),
      Failure(:final message) => state.copyWith(
          status: BrowseStatus.error,
          message: message,
        ),
    });
  }

  void selectDepartment(String? slug) {
    if (slug == state.department) return;
    emit(state.copyWith(department: () => slug));
    load();
  }

  void selectSort(BrowseSort sort) {
    if (sort == state.sort) return;
    emit(state.copyWith(sort: sort));
    load();
  }
}
