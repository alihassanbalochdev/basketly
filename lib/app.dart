import 'package:basketly/core/router/app_router.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/theme/bk_theme.dart';
import 'package:basketly/features/auth/data/auth_repository.dart';
import 'package:basketly/features/basket/data/basket_storage.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_cubit.dart';
import 'package:basketly/features/catalog/data/catalog_repository.dart';
import 'package:basketly/features/checkout/data/checkout_repository.dart';
import 'package:basketly/features/orders/data/orders_repository.dart';
import 'package:basketly/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BasketlyApp extends StatefulWidget {
  const BasketlyApp({super.key, required this.supabase});

  final SupabaseClient supabase;

  @override
  State<BasketlyApp> createState() => _BasketlyAppState();
}

class _BasketlyAppState extends State<BasketlyApp> {
  // Built once. Rebuilding a GoRouter on every build would reset navigation.
  late final GoRouter _router = buildRouter(widget.supabase);

  @override
  Widget build(BuildContext context) {
    // Repositories: plain objects that talk to Supabase.
    // Blocs/Cubits: hold app state and are created from repositories.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => CatalogRepository(widget.supabase)),
        RepositoryProvider(create: (_) => AuthRepository(widget.supabase)),
        RepositoryProvider(create: (_) => CheckoutRepository(widget.supabase)),
        RepositoryProvider(create: (_) => OrdersRepository(widget.supabase)),
      ],
      child: MultiBlocProvider(
        providers: [
          // The basket lives above the router, so every screen shares it.
          // ..restore() brings back the basket saved last time.
          BlocProvider(create: (_) => BasketCubit(BasketStorage())..restore()),
          // Orders too: it loads itself when someone signs in.
          BlocProvider(create: (context) => OrdersCubit(context.read<OrdersRepository>())),
        ],
        child: MaterialApp.router(
          title: 'Basketly',
          debugShowCheckedModeBanner: false,
          theme: BkTheme.light(),
          routerConfig: _router,
        ),
      ),
    );
  }
}

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: BkTheme.light(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Supabase keys are missing. Run the app with '
              '--dart-define-from-file=env.json',
              textAlign: TextAlign.center,
              style: BkText.body,
            ),
          ),
        ),
      ),
    );
  }
}
