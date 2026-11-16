import 'package:basketly/core/router/app_shell.dart';
import 'package:basketly/core/router/auth_listenable.dart';
import 'package:basketly/features/account/presentation/account_screen.dart';
import 'package:basketly/features/auth/data/auth_repository.dart';
import 'package:basketly/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:basketly/features/auth/presentation/sign_in_screen.dart';
import 'package:basketly/features/basket/presentation/basket_screen.dart';
import 'package:basketly/features/catalog/data/catalog_repository.dart';
import 'package:basketly/features/catalog/presentation/browse_screen.dart';
import 'package:basketly/features/catalog/presentation/cubit/browse_cubit.dart';
import 'package:basketly/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:basketly/features/catalog/presentation/cubit/product_cubit.dart';
import 'package:basketly/features/catalog/presentation/home_screen.dart';
import 'package:basketly/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:basketly/features/catalog/presentation/product_screen.dart';
import 'package:basketly/features/catalog/presentation/search_screen.dart';
import 'package:basketly/features/checkout/data/checkout_repository.dart';
import 'package:basketly/features/checkout/domain/placed_order.dart';
import 'package:basketly/features/checkout/presentation/checkout_screen.dart';
import 'package:basketly/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:basketly/features/checkout/presentation/order_placed_screen.dart';
import 'package:basketly/features/orders/data/orders_repository.dart';
import 'package:basketly/features/orders/presentation/cubit/tracking_cubit.dart';
import 'package:basketly/features/orders/presentation/orders_screen.dart';
import 'package:basketly/features/orders/presentation/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Screens you must be signed in to see.
const _needsSignIn = {'/checkout', '/orders', '/account'};

GoRouter buildRouter(SupabaseClient client) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    // Re-runs `redirect` whenever someone signs in or out.
    refreshListenable: AuthListenable(client),
    redirect: (context, state) {
      final signedIn = client.auth.currentUser != null;
      final path = state.matchedLocation;

      if (!signedIn && (_needsSignIn.contains(path) || path.startsWith('/order/'))) {
        return '/sign-in?next=${Uri.encodeComponent(state.uri.toString())}';
      }
      // Just signed in: carry on to where they were going.
      if (signedIn && path == '/sign-in') {
        return state.uri.queryParameters['next'] ?? '/home';
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              // The cubit belongs to this screen: created when Home opens,
              // closed automatically when it is removed.
              builder: (context, state) => BlocProvider(
                create: (context) =>
                    HomeCubit(context.read<CatalogRepository>())..load(),
                child: const HomeScreen(),
              ),
              routes: [
                // /home/search sits inside the Home tab, so the nav bar and
                // the basket stay visible and products can still fly in.
                GoRoute(
                  path: 'search',
                  builder: (context, state) => BlocProvider(
                    create: (context) => SearchCubit(context.read<CatalogRepository>()),
                    child: const SearchScreen(),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              // /browse or /browse?dept=fashion
              path: '/browse',
              builder: (context, state) {
                final department = state.uri.queryParameters['dept'];
                return BlocProvider(
                  // A new department in the link means a fresh cubit.
                  key: ValueKey(department),
                  create: (context) => BrowseCubit(
                    context.read<CatalogRepository>(),
                    department: department,
                  )..load(),
                  child: const BrowseScreen(),
                );
              },
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountScreen(),
            ),
          ]),
        ],
      ),
      // These open above the tabs, so the nav bar is hidden.
      GoRoute(
        path: '/product/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => BlocProvider(
          create: (context) => ProductCubit(
            context.read<CatalogRepository>(),
            state.pathParameters['id']!,
          )..load(),
          child: const ProductScreen(),
        ),
      ),
      GoRoute(
        path: '/basket',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const BasketScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => BlocProvider(
          create: (context) => SignInCubit(context.read<AuthRepository>()),
          child: const SignInScreen(),
        ),
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => BlocProvider(
          create: (context) => CheckoutCubit(context.read<CheckoutRepository>())..load(),
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: '/order/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => BlocProvider(
          create: (context) => TrackingCubit(
            context.read<OrdersRepository>(),
            state.pathParameters['id']!,
          )..load(),
          child: const TrackingScreen(),
        ),
      ),
      GoRoute(
        path: '/order-placed',
        parentNavigatorKey: _rootKey,
        // Opened only right after ordering; a bare link goes home.
        redirect: (context, state) => state.extra is PlacedOrder ? null : '/home',
        builder: (context, state) => OrderPlacedScreen(order: state.extra! as PlacedOrder),
      ),
    ],
  );
}
