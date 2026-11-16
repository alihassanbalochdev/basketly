import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/catalog/domain/home_data.dart';
import 'package:basketly/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:basketly/features/catalog/presentation/cubit/home_state.dart';
import 'package:basketly/features/catalog/presentation/widgets/buy_again_row.dart';
import 'package:basketly/features/catalog/presentation/widgets/deal_card.dart';
import 'package:basketly/features/catalog/presentation/widgets/department_grid.dart';
import 'package:basketly/features/catalog/presentation/widgets/home_error_view.dart';
import 'package:basketly/features/catalog/presentation/widgets/home_header.dart';
import 'package:basketly/features/catalog/presentation/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => switch (state) {
            HomeLoading() => const Center(child: CircularProgressIndicator()),
            HomeError(:final message) => HomeErrorView(
                message: message,
                onRetry: context.read<HomeCubit>().load,
              ),
            HomeLoaded(:final data) => _HomeContent(data: data),
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final departments = data.departments;

    return RefreshIndicator(
      onRefresh: context.read<HomeCubit>().load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          BkSpace.xl, BkSpace.lg, BkSpace.xl, BkSpace.navClearance,
        ),
        children: [
          const HomeHeader(),
          const SizedBox(height: 14),
          const SearchField(),
          // Extra room: the deal's product image pokes out above the card.
          if (data.deal case final deal?) ...[
            const SizedBox(height: 34),
            DealCard(product: deal),
          ],
          const SizedBox(height: 22),
          const Text('Shop by department', style: BkText.heading),
          const SizedBox(height: BkSpace.md),
          DepartmentGrid(departments: departments),
          if (data.buyAgain.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Text('Buy it again', style: BkText.heading),
            const SizedBox(height: BkSpace.md),
            BuyAgainRow(products: data.buyAgain, departments: departments),
          ],
        ],
      ),
    );
  }
}
