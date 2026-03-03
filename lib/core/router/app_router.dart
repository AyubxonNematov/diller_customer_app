import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/debug/alice_setup.dart';
import 'package:sement_market_customer/core/firebase/firebase_notifications.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';
import 'package:sement_market_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sement_market_customer/features/dealers/data/models/dealer_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/dealers_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/products_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/warehouses_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/pages/dealer_warehouses_page.dart';
import 'package:sement_market_customer/features/dealers/presentation/pages/dealers_page.dart';
import 'package:sement_market_customer/features/dealers/presentation/pages/warehouse_products_page.dart';
import 'package:sement_market_customer/features/auth/presentation/pages/login_page.dart';
import 'package:sement_market_customer/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sement_market_customer/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sement_market_customer/features/profile/presentation/pages/profile_page.dart';

abstract class AppRouter {
  static List<BlocProvider> get providers => [
        BlocProvider(create: (_) => AuthBloc()),
      ];

  static GoRouter get router => GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/login',
        redirect: (context, state) async {
          final loc = state.matchedLocation;
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          final isLoginRoute = loc == '/login';
          if (token != null && isLoginRoute) return '/diller';
          if (token == null && !isLoginRoute) return '/login';
          return null;
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (_, __) => BlocProvider(
              create: (_) => AuthBloc(),
              child: const LoginPage(),
            ),
          ),
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) => BlocProvider(
              create: (_) => ProfileBloc()..add(const ProfileLoad()),
              child: _FcmSyncWrapper(
                child: _MainShell(navigationShell: navigationShell),
              ),
            ),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/diller',
                    routes: [
                      GoRoute(
                        path: ':id',
                        routes: [
                          GoRoute(
                            path: 'w/:warehouseId',
                            builder: (context, state) {
                              final warehouse =
                                  state.extra as WarehouseModel?;
                              if (warehouse == null) {
                                return const SizedBox.shrink();
                              }
                              return BlocProvider(
                                create: (_) =>
                                    ProductsBloc(warehouse: warehouse),
                                child: WarehouseProductsPage(
                                  warehouse: warehouse,
                                ),
                              );
                            },
                          ),
                        ],
                        builder: (context, state) {
                          final dealer = state.extra as DealerModel?;
                          if (dealer == null) {
                            return const SizedBox.shrink();
                          }
                          return BlocProvider(
                            create: (_) => WarehousesBloc(dealer: dealer),
                            child: DealerWarehousesPage(dealer: dealer),
                          );
                        },
                      ),
                    ],
                    builder: (_, __) => BlocProvider(
                      create: (_) => DealersBloc(),
                      child: const DealersPage(),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/zakazlar',
                    builder: (c, __) => _PlaceholderPage(
                      title: AppLocalizations.of(c)!.zakazlar,
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/savat',
                    builder: (c, __) => _PlaceholderPage(
                      title: AppLocalizations.of(c)!.savat,
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder: (_, __) => const ProfilePage(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsPage(),
          ),
        ],
      );
}

class _FcmSyncWrapper extends StatefulWidget {
  const _FcmSyncWrapper({required this.child});
  final Widget child;

  @override
  State<_FcmSyncWrapper> createState() => _FcmSyncWrapperState();
}

class _FcmSyncWrapperState extends State<_FcmSyncWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseNotificationsService.sendFcmTokenIfAuthenticated();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (i) => navigationShell.goBranch(i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.darkNavy,
          unselectedItemColor: AppColors.grayText,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.store_outlined),
              activeIcon: const Icon(Icons.store),
              label: AppLocalizations.of(context)!.navDiller,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: AppLocalizations.of(context)!.navZakazlar,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              activeIcon: const Icon(Icons.shopping_cart),
              label: AppLocalizations.of(context)!.navSavat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: AppLocalizations.of(context)!.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Text(title,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy)),
      ),
    );
  }
}
