import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/widgets/round_icon_button.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:basketly/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:basketly/features/catalog/presentation/cubit/search_state.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:basketly/features/catalog/presentation/widgets/home_error_view.dart';
import 'package:basketly/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _text = TextEditingController();

  static const _suggestions = ['Milk', 'Rice', 'Kurta', 'Sneakers', 'Earbuds', 'Kettle'];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _use(String word) {
    _text.text = word;
    _text.selection = TextSelection.collapsed(offset: word.length);
    context.read<SearchCubit>().queryChanged(word);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.lg, BkSpace.xl, BkSpace.md),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  const SizedBox(width: BkSpace.md),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: const BoxDecoration(
                        color: BkColors.surface,
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        boxShadow: BkShadow.subtle,
                      ),
                      child: ListenableBuilder(
                        // Rebuilds only the clear button as the text changes.
                        listenable: _text,
                        builder: (context, _) => TextField(
                          controller: _text,
                          autofocus: true,
                          style: BkText.body,
                          textInputAction: TextInputAction.search,
                          onChanged: cubit.queryChanged,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search milk, kurtas, phones…',
                            hintStyle: BkText.small,
                            prefixIcon: const Icon(Icons.search_rounded, color: BkColors.muted),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            suffixIcon: _text.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear',
                                    icon: const Icon(Icons.close_rounded, size: 20),
                                    onPressed: () => _use(''),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) => switch (state.status) {
                  SearchStatus.idle => _Suggestions(words: _suggestions, onTap: _use),
                  SearchStatus.loading when state.results.isEmpty =>
                    const Center(child: CircularProgressIndicator()),
                  SearchStatus.error => HomeErrorView(message: state.message, onRetry: cubit.retry),
                  SearchStatus.ready when state.results.isEmpty => _NoResults(query: state.query),
                  // While typing, the last results stay on screen.
                  _ => _Results(products: state.results),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.words, required this.onTap});

  final List<String> words;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.md, BkSpace.xl, BkSpace.navClearance),
      children: [
        const Text('Popular right now', style: BkText.label),
        const SizedBox(height: BkSpace.md),
        Wrap(
          spacing: BkSpace.sm,
          runSpacing: BkSpace.sm,
          children: [
            for (final word in words)
              ActionChip(
                label: Text(word),
                onPressed: () => onTap(word),
                backgroundColor: BkColors.surface,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                labelStyle: BkText.label,
              ),
          ],
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(BkSpace.xxl),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.search_off_rounded, size: 44, color: BkColors.muted),
          const SizedBox(height: BkSpace.md),
          Text('Nothing matches "$query"', style: BkText.heading, textAlign: TextAlign.center),
          const SizedBox(height: BkSpace.sm),
          const Text('Try a shorter word, like "rice" or "watch".', style: BkText.small),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Scrolling the results hides the keyboard.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.sm, BkSpace.xl, BkSpace.navClearance),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 22,
        crossAxisSpacing: 14,
        mainAxisExtent: 272, // same card height as Browse
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product, tint: product.tint, iconColor: product.deepTint);
      },
    );
  }
}
