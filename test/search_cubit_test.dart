import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/catalog/data/catalog_repository.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:basketly/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:basketly/features/catalog/presentation/cubit/search_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Answers searches from a list instead of Supabase, and counts calls.
class _FakeCatalog extends CatalogRepository {
  _FakeCatalog() : super(SupabaseClient('http://localhost', 'test-key'));

  int calls = 0;

  static const _kettle = Product(
    id: 'k', departmentSlug: 'home', name: 'Electric kettle', subtitle: '', price: 3750,
  );

  @override
  Future<Result<List<Product>>> search(String query) async {
    calls++;
    return Success(query.contains('ket') ? [_kettle] : []);
  }
}

void main() {
  test('typing quickly sends one search, after the pause', () async {
    final repo = _FakeCatalog();
    final cubit = SearchCubit(repo);

    for (final text in ['ke', 'ket', 'kett', 'kettle']) {
      cubit.queryChanged(text);
    }
    expect(repo.calls, 0); // still waiting for the pause

    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(repo.calls, 1);
    expect(cubit.state.status, SearchStatus.ready);
    expect(cubit.state.results.single.name, 'Electric kettle');
    await cubit.close();
  });

  test('one letter shows suggestions without searching', () async {
    final repo = _FakeCatalog();
    final cubit = SearchCubit(repo)..queryChanged('k');

    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(repo.calls, 0);
    expect(cubit.state.status, SearchStatus.idle);
    await cubit.close();
  });
}
