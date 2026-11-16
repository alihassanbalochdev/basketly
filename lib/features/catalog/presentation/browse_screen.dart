import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/catalog/presentation/cubit/browse_cubit.dart';
import 'package:basketly/features/catalog/presentation/cubit/browse_state.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:basketly/features/catalog/presentation/widgets/department_chips.dart';
import 'package:basketly/features/catalog/presentation/widgets/home_error_view.dart';
import 'package:basketly/features/catalog/presentation/widgets/product_card.dart';
import 'package:basketly/features/catalog/presentation/widgets/sort_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<BrowseCubit, BrowseState>(
          builder: (context, state) {
            final cubit = context.read<BrowseCubit>();
            final title = state.selectedDepartment?.name ?? 'Everything';
            final firstLoad = state.status == BrowseStatus.loading && state.products.isEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.xxl, BkSpace.xl, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Text(title, style: BkText.display)),
                      if (state.status == BrowseStatus.ready)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text('${state.products.length} products', style: BkText.small),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: BkSpace.lg),
                DepartmentChips(
                  departments: state.departments,
                  selected: state.department,
                  onSelected: cubit.selectDepartment,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: BkSpace.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [SortButton(sort: state.sort, onSelected: cubit.selectSort)],
                  ),
                ),
                // A thin bar while new results load, so the grid doesn't blank out.
                SizedBox(
                  height: 2,
                  child: state.status == BrowseStatus.loading && !firstLoad
                      ? const LinearProgressIndicator()
                      : null,
                ),
                Expanded(
                  child: switch (state.status) {
                    _ when firstLoad => const Center(child: CircularProgressIndicator()),
                    BrowseStatus.error => HomeErrorView(message: state.message, onRetry: cubit.load),
                    _ when state.products.isEmpty => const Center(
                        child: Text('Nothing here yet. Try another department.', style: BkText.small),
                      ),
                    _ => _ProductGrid(state: state),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.state});

  final BrowseState state;

  @override
  Widget build(BuildContext context) {
    final bySlug = {for (final d in state.departments) d.slug: d};

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.sm, BkSpace.xl, BkSpace.navClearance),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 22,
        crossAxisSpacing: 14,
        mainAxisExtent: 272, // fixed card height: image + three lines of text
      ),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        final product = state.products[index];
        final department = bySlug[product.departmentSlug];
        return ProductCard(
          product: product,
          tint: department?.tint,
          iconColor: department?.deepTint,
        );
      },
    );
  }
}
