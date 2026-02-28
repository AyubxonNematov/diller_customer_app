import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/debug/alice_setup.dart';
import 'package:sement_market_customer/core/permissions/permission_page.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sement_market_customer/features/auth/presentation/pages/login_page.dart';
import 'package:sement_market_customer/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sement_market_customer/features/profile/presentation/pages/profile_page.dart';

abstract class AppRouter {
  static List<BlocProvider> get providers => [
        BlocProvider(create: (_) => AuthBloc()),
      ];

  static GoRouter get router => GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/permissions',
        redirect: (context, state) async {
          final loc = state.matchedLocation;
          if (loc == '/permissions') return null;
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          final isLoginRoute = loc == '/login';
          if (token != null && isLoginRoute) return '/profile';
          if (token == null && !isLoginRoute) return '/login';
          return null;
        },
        routes: [
          GoRoute(
            path: '/permissions',
            builder: (_, __) => const PermissionPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => BlocProvider(
              create: (_) => AuthBloc(),
              child: const LoginPage(),
            ),
          ),
          ShellRoute(
            builder: (context, state, child) =>
                _MainShell(location: state.matchedLocation, child: child),
            routes: [
              GoRoute(
                path: '/diller',
                builder: (_, __) => const _PlaceholderPage(title: 'Diller'),
              ),
              GoRoute(
                path: '/zakazlar',
                builder: (_, __) => const _PlaceholderPage(title: 'Zakazlar'),
              ),
              GoRoute(
                path: '/savat',
                builder: (_, __) => const _PlaceholderPage(title: 'Savat'),
              ),
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfilePage(),
              ),
              GoRoute(
                path: '/notifications',
                builder: (_, __) => const NotificationsPage(),
              ),
            ],
          ),
        ],
      );
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.location, required this.child});
  final String location;
  final Widget child;

  int get _currentIndex {
    if (location.startsWith('/diller')) return 0;
    if (location.startsWith('/zakazlar')) return 1;
    if (location.startsWith('/savat')) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
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
          currentIndex: _currentIndex,
          onTap: (i) {
            const routes = ['/diller', '/zakazlar', '/savat', '/profile'];
            context.go(routes[i]);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.darkNavy,
          unselectedItemColor: AppColors.grayText,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.store),
              label: 'DILLER',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'ZAKAZLAR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'SAVAT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFIL',
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                color: AppColors.darkNavy)),
      ),
    );
  }
}
