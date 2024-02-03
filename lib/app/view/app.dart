import 'package:flutter/material.dart';
import 'package:walkly/l10n/l10n.dart';
import 'package:walkly/router/router.dart';

class App extends StatelessWidget {
  App({super.key});

  final router = AppRoute.router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
