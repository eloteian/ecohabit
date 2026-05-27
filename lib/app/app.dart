// =============================================================================
// app.dart — Widget raíz de EcoHabit
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../features/settings/providers/settings_provider.dart';
import 'routes.dart';
import 'theme.dart';

class EcoHabitApp extends StatelessWidget {
  const EcoHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'EcoHabit',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          locale: const Locale('es', 'MX'),
          supportedLocales: const [
            Locale('es', 'MX'),
            Locale('es', 'CO'),
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          initialRoute: AppRoutes.splash,
          routes: appRoutes,
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}
