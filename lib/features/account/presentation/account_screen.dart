import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/auth/data/auth_repository.dart';
import 'package:basketly/features/checkout/data/checkout_repository.dart';
import 'package:basketly/features/checkout/domain/delivery_address.dart';
import 'package:basketly/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:basketly/features/orders/presentation/cubit/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Started once here, not in build, so it isn't fetched on every rebuild.
  late final Future<DeliveryAddress?> _address =
      context.read<CheckoutRepository>().loadAddress();

  Future<void> _signOut() async {
    final auth = context.read<AuthRepository>();
    // Leave the signed-in tab first, so the router doesn't send us to sign-in.
    context.go('/home');
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = context.read<AuthRepository>().email ?? '';
    final orderCount = context.select<OrdersCubit, int?>(
      (cubit) => switch (cubit.state) {
        OrdersLoaded(:final orders) => orders.length,
        _ => null,
      },
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(BkSpace.xl, BkSpace.lg, BkSpace.xl, BkSpace.navClearance),
          children: [
            const Text('Account', style: BkText.title),
            const SizedBox(height: BkSpace.xl),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: BkColors.plum,
                  child: Text(
                    email.isEmpty ? '?' : email[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800, color: BkColors.saffron,
                    ),
                  ),
                ),
                const SizedBox(width: BkSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email, style: BkText.bodyStrong, overflow: TextOverflow.ellipsis),
                      if (orderCount != null)
                        Text(
                          orderCount == 1 ? '1 order' : '$orderCount orders',
                          style: BkText.small,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: BkSpace.xxl),
            _Group(
              children: [
                _Row(
                  icon: Icons.inventory_2_outlined,
                  title: 'Your orders',
                  onTap: () => context.go('/orders'),
                ),
                FutureBuilder(
                  future: _address,
                  builder: (context, snapshot) => _Row(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery address',
                    subtitle: snapshot.data?.oneLine ?? 'Added at your first checkout',
                  ),
                ),
                const _Row(
                  icon: Icons.local_offer_outlined,
                  title: 'Promo code',
                  subtitle: 'BASKET10 takes 10% off, up to Rs 500',
                ),
              ],
            ),
            const SizedBox(height: BkSpace.lg),
            _Group(
              children: [
                _Row(
                  icon: Icons.logout_rounded,
                  title: 'Sign out',
                  color: const Color(0xFFB3261E),
                  onTap: _signOut,
                ),
              ],
            ),
            const SizedBox(height: BkSpace.xl),
            const Text(
              'Basketly is a portfolio demo. Card payments and the rider are not real.',
              textAlign: TextAlign.center,
              style: BkText.tiny,
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BkColors.surface,
      borderRadius: BkRadius.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Divider(height: 1, indent: 56, color: BkColors.line),
            child,
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.color = BkColors.ink,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color == BkColors.ink ? BkColors.plum : color),
      title: Text(title, style: BkText.bodyStrong.copyWith(color: color)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: BkText.small),
      trailing: onTap == null || color != BkColors.ink
          ? null
          : const Icon(Icons.chevron_right_rounded, color: BkColors.muted),
    );
  }
}
