import 'package:basketly/features/catalog/domain/product.dart';
import 'package:equatable/equatable.dart';

/// idle: nothing typed yet, so the screen shows suggestions.
enum SearchStatus { idle, loading, ready, error }

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.status = SearchStatus.idle,
    this.results = const [],
    this.message = '',
  });

  final String query;
  final SearchStatus status;
  final List<Product> results;
  final String message;

  SearchState copyWith({
    String? query,
    SearchStatus? status,
    List<Product>? results,
    String? message,
  }) {
    return SearchState(
      query: query ?? this.query,
      status: status ?? this.status,
      results: results ?? this.results,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [query, status, results, message];
}
