import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/utils/money.dart';
import 'package:basketly/core/widgets/price_text.dart';
import 'package:basketly/core/widgets/product_image.dart';
import 'package:basketly/core/widgets/round_icon_button.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_state.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_button.dart';
import 'package:basketly/features/basket/presentation/widgets/fly_to_basket.dart';
import 'package:basketly/features/catalog/domain/department.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:basketly/features/catalog/presentation/cubit/product_cubit.dart';
import 'package:basketly/features/catalog/presentation/cubit/product_state.dart';
import 'package:basketly/features/catalog/presentation/department_style.dart';
import 'package:basketly/features/catalog/presentation/widgets/add_to_basket_bar.dart';
import 'package:basketly/features/catalog/presentation/widgets/colour_picker.dart';
import 'package:basketly/features/catalog/presentation/widgets/flying_thumb.dart';
import 'package:basketly/features/catalog/presentation/widgets/home_error_view.dart';
import 'package:basketly/features/catalog/presentation/widgets/size_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) => switch (state) {
          ProductLoading() => const Center(child: CircularProgressIndicator()),
          ProductError(:final message) => SafeArea(
              child: HomeErrorView(message: message, onRetry: context.read<ProductCubit>().load),
            ),
          ProductLoaded(:final detail) => _ProductView(
              product: detail.product,
              department: detail.department,
            ),
        },
      ),
    );
  }
}

class _ProductView extends StatefulWidget {
  const _ProductView({required this.product, required this.department});

  final Product product;
  final Department department;

  @override
  State<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<_ProductView> {
  final _addKey = GlobalKey(); // flight starts here
  final _basketKey = GlobalKey(); // and lands here

  int _colour = 0; // index into product.colours
  String? _size; // no size chosen yet
  int _quantity = 1;
  bool _justAdded = false;

  Product get _product => widget.product;

  void _add() {
    final basket = context.read<BasketCubit>();
    final colour = _product.colours.isEmpty ? null : _product.colours[_colour].name;
    final quantity = _quantity;
    final size = _size;

    FlyToBasket.launch(
      context: context,
      from: _addKey,
      to: _basketKey,
      child: FlyingThumb(
        product: _product,
        tint: widget.department.tint,
        iconColor: widget.department.deepTint,
      ),
      onLanded: () {
        basket.add(_product, quantity: quantity, size: size, colour: colour);
        if (!mounted) return;
        setState(() => _justAdded = true);
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) setState(() => _justAdded = false);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final department = widget.department;
    final saving = product.saving;
    final topInset = MediaQuery.paddingOf(context).top;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ---- picture with floating buttons ----
              Container(
                height: 372 + topInset,
                decoration: BoxDecoration(
                  color: department.tint,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: topInset + 20),
                        child: ProductImage(
                          imageUrl: product.imageUrl,
                          fallbackIcon: department.icon,
                          size: 230,
                          iconColor: department.deepTint,
                        ),
                      ),
                    ),
                    Positioned(
                      top: topInset + BkSpace.lg,
                      left: BkSpace.xl,
                      right: BkSpace.xl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RoundIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Back',
                            onPressed: () => context.pop(),
                          ),
                          BlocBuilder<BasketCubit, BasketState>(
                            builder: (context, basket) => BasketButton(
                              key: _basketKey,
                              size: 44,
                              ringColor: department.tint,
                              count: basket.itemCount,
                              fill: basket.freeDeliveryProgress,
                              onTap: () => context.push('/basket'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ---- details ----
              Padding(
                padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.xl, BkSpace.xl, BkSpace.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: BkText.title),
                    if (product.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(product.subtitle, style: BkText.small.copyWith(fontSize: 14)),
                    ],
                    const SizedBox(height: BkSpace.md),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        PriceText(price: product.price, wasPrice: product.wasPrice, size: 26, color: BkColors.plum),
                        if (saving != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: BkColors.saffron,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Save ${rs(saving)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: BkColors.ink),
                            ),
                          ),
                      ],
                    ),
                    if (product.colours.isNotEmpty) ...[
                      const SizedBox(height: BkSpace.xl),
                      ColourPicker(
                        colours: product.colours,
                        selected: _colour,
                        onSelected: (index) => setState(() => _colour = index),
                      ),
                    ],
                    if (product.needsSize) ...[
                      const SizedBox(height: BkSpace.lg),
                      SizePicker(
                        sizes: product.sizes,
                        soldOut: product.soldOutSizes,
                        selected: _size,
                        onSelected: (size) => setState(() => _size = size),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        AddToBasketBar(
          addButtonKey: _addKey,
          quantity: _quantity,
          onQuantityChanged: (q) => setState(() => _quantity = q),
          // A size must be picked first; the button says so.
          onAdd: product.needsSize && _size == null ? null : _add,
          label: switch ((_justAdded, product.needsSize && _size == null)) {
            (true, _) => 'Added to basket',
            (_, true) => 'Choose a size',
            _ => 'Add to basket',
          },
        ),
      ],
    );
  }
}
