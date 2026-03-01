import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/locale/app_locale.dart';
import 'package:sement_market_customer/core/router/app_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class SementMarketCustomerApp extends StatelessWidget {
  const SementMarketCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocale = getIt<AppLocale>();
    return ListenableBuilder(
      listenable: appLocale,
      builder: (context, _) {
        return MultiBlocProvider(
          providers: AppRouter.providers,
          child: MaterialApp.router(
            title: 'Sement Market',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appLocale.locale,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
