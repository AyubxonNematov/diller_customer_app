import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/debug/alice_setup.dart';
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
          ShellRoute(
            builder: (context, state, child) =>
                _MainShell(location: state.matchedLocation, child: child),
            routes: [
              GoRoute(
                path: '/diller',
                builder: (_, __) => const _DillerPage(),
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
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy)),
      ),
    );
  }
}

class _DillerPage extends StatefulWidget {
  const _DillerPage();

  @override
  State<_DillerPage> createState() => _DillerPageState();
}

class _DillerPageState extends State<_DillerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLocation());
  }

  Future<void> _checkLocation() async {
    if (!mounted) return;
    final status = await Geolocator.checkPermission();
    if (!mounted) return;
    if (status == LocationPermission.denied ||
        status == LocationPermission.unableToDetermine) {
      _showLocationDialog(deniedForever: false);
    } else if (status == LocationPermission.deniedForever) {
      _showLocationDialog(deniedForever: true);
    }
  }

  void _showLocationDialog({required bool deniedForever}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF4C400).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFF4C400),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Joylashuvga ruxsat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0E1A33),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Yaqin dillerlarni topish uchun joylashuvingizga ruxsat bering',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9EA6B3),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0E1A33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  if (deniedForever) {
                    await Geolocator.openAppSettings();
                  } else {
                    await Geolocator.requestPermission();
                  }
                },
                child: Text(
                  deniedForever ? 'Sozlamalarga o\'tish' : 'Ruxsat berish',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Keyinroq',
                style: TextStyle(color: Color(0xFF9EA6B3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text(
          'DILLER',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkNavy,
          ),
        ),
      ),
    );
  }
}
