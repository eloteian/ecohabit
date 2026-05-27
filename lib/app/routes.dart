// =============================================================================
// routes.dart — Sistema de navegación centralizado de EcoHabit
// -----------------------------------------------------------------------------
// Implementa un enrutador declarativo basado en named routes de Flutter.
// Cada identificador de ruta es una constante String para evitar errores
// tipográficos en Navigator.pushNamed() a lo largo del código.
//
// Pantallas del flujo (8 screens):
//   1. /           → SplashScreen      — Carga y validación de onboarding
//   2. /onboarding → WelcomeScreen     — Bienvenida + panel de login (morfismo)
//   3. /home       → HomeScreen        — Dashboard principal
//   4. /habit-form → HabitFormScreen   — Crear / editar hábito
//   5. /statistics → StatisticsScreen  — Gráficas de impacto ambiental
//   6. /profile    → ProfileScreen     — Perfil y logros del usuario
//   7. /settings   → SettingsScreen    — Configuración de la app
//   8. /about      → AboutScreen       — Licencia y créditos
// =============================================================================

import 'package:flutter/material.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/onboarding/presentation/user_setup_screen.dart';
import '../features/home/screens/main_shell.dart';
import '../features/habits/screens/habit_form_screen.dart';
import '../features/statistics/screens/statistics_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/about_screen.dart';

/// Identificadores de rutas nombradas de la aplicación.
abstract final class AppRoutes {
  static const String splash      = '/';
  static const String onboarding  = '/onboarding';
  static const String userSetup   = '/user-setup';
  static const String home        = '/home';
  static const String statistics  = '/statistics';
  static const String profile     = '/profile';
  static const String habitForm   = '/habit-form';
  static const String settings    = '/settings';
  static const String about       = '/about';
}

/// Mapa de rutas para [MaterialApp.routes].
Map<String, WidgetBuilder> get appRoutes => {
      AppRoutes.splash: (_) => const SplashScreen(),
      AppRoutes.onboarding: (_) => const WelcomeScreen(),
      AppRoutes.userSetup:  (_) => const UserSetupScreen(loginMethod: 'email'),
      AppRoutes.home: (_) => const MainShellScreen(),
      AppRoutes.habitForm: (_) => const HabitFormScreen(),
      AppRoutes.statistics: (_) => const StatisticsScreen(),
      AppRoutes.profile: (_) => const ProfileScreen(),
      AppRoutes.settings: (_) => const SettingsScreen(),
      AppRoutes.about: (_) => const AboutScreen(),
    };

/// Genera rutas con transiciones personalizadas (slide + fade estilo iOS).
///
/// Se activa solo para rutas de detalle que no están en el tab bar.
/// Las rutas principales usan el mapa [appRoutes] directamente.
Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
  final name = routeSettings.name;

  // Rutas de detalle — slide horizontal
  if (name == AppRoutes.habitForm || name == AppRoutes.about) {
    final builder = appRoutes[name];
    if (builder != null) {
      return _slideRoute(builder: builder, settings: routeSettings);
    }
  }

  // Ruta por defecto — fade transition
  final builder = appRoutes[name];
  if (builder != null) {
    return _fadeRoute(builder: builder, settings: routeSettings);
  }

  // Ruta no encontrada
  return MaterialPageRoute(
    builder: (_) => const _RouteNotFoundScreen(),
    settings: routeSettings,
  );
}

// ---------------------------------------------------------------------------
// Constructores de rutas con transiciones personalizadas
// ---------------------------------------------------------------------------

PageRouteBuilder<T> _fadeRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (ctx, _, __) => builder(ctx),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 250),
  );
}

PageRouteBuilder<T> _slideRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (ctx, _, __) => builder(ctx),
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        ),
      );
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// ---------------------------------------------------------------------------
// Pantalla de error para rutas no registradas
// ---------------------------------------------------------------------------

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_outlined, size: 64, color: Color(0xFF4E9A78)),
            const SizedBox(height: 16),
            Text('Página no encontrada',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Esta ruta no existe en EcoHabit.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.home),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
