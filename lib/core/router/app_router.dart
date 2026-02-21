import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sement_market_customer/features/auth/presentation/pages/login_page.dart';
import 'package:sement_market_customer/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:sement_market_customer/features/notifications/presentation/pages/notifications_page.dart';

abstract class AppRouter {
  static List<BlocProvider> get providers => [
        BlocProvider(create: (_) => AuthBloc()),
      ];

  static GoRouter get router => GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
          GoRoute(path: '/profile-setup', builder: (_, __) => const ProfileSetupPage()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
        ],
      );
}
