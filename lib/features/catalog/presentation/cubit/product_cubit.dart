import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/catalog/data/catalog_repository.dart';
import 'package:basketly/features/catalog/presentation/cubit/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads one product. The size, colour and quantity the shopper is
/// choosing live in the screen itself: they are temporary form state,
/// and nothing else in the app needs them until "Add to basket".
class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._repository, this.productId) : super(const ProductLoading());

  final CatalogRepository _repository;
  final String productId;

  Future<void> load() async {
    emit(const ProductLoading());
    final result = await _repository.loadProduct(productId);
    if (isClosed) return;

    emit(switch (result) {
      Success(:final value) => ProductLoaded(value),
      Failure(:final message) => ProductError(message),
    });
  }
}
