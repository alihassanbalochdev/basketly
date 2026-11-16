import 'dart:async';

import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/catalog/data/catalog_repository.dart';
import 'package:basketly/features/catalog/presentation/cubit/search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchState());

  final CatalogRepository _repository;
  Timer? _debounce;
  int _request = 0;

  /// Called on every key press. Waits until typing pauses for 300 ms,
  /// so "kettle" is one request, not six.
  void queryChanged(String text) {
    final query = text.trim();
    _debounce?.cancel();

    if (query.length < 2) {
      _request++; // ignore any search still on its way
      emit(SearchState(query: query));
      return;
    }
    emit(state.copyWith(query: query, status: SearchStatus.loading));
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  Future<void> retry() => _search(state.query);

  Future<void> _search(String query) async {
    // Same race guard as Browse: only the newest search may answer.
    final request = ++_request;
    emit(state.copyWith(status: SearchStatus.loading));

    final result = await _repository.search(query);
    if (isClosed || request != _request) return;

    emit(switch (result) {
      Success(:final value) => state.copyWith(status: SearchStatus.ready, results: value),
      Failure(:final message) => state.copyWith(status: SearchStatus.error, message: message),
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
