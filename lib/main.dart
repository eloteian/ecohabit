// =============================================================================
// main.dart — Punto de entrada de EcoHabit
// =============================================================================
// EcoHabit: Rastreador de Hábitos Sostenibles Premium
// Versión: 1.0.0
// Licencia: MIT License
//
// Copyright (c) 2026 EcoHabit Development Team
//
// Se otorga permiso, de forma gratuita, a cualquier persona que obtenga una
// copia de este software y los archivos de documentación asociados (el
// "Software"), para utilizar el Software sin restricción, incluyendo sin
// limitación los derechos de usar, copiar, modificar, fusionar, publicar,
// distribuir, sublicenciar y/o vender copias del Software, y para permitir
// que las personas a las que se les proporcione el Software lo hagan, sujeto
// a las siguientes condiciones:
//
// El aviso de copyright anterior y este aviso de permiso se incluirán en
// todas las copias o porciones sustanciales del Software.
//
// EL SOFTWARE SE PROPORCIONA "TAL CUAL", SIN GARANTÍA DE NINGÚN TIPO.
// =============================================================================
//
// ARQUITECTURA: Feature-first + Provider (patrón InheritedWidget)
// PERSISTENCIA: shared_preferences (almacenamiento local nativo)
// COMPATIBILIDAD: Android 5.0+ (API 21) / iOS 13.0+
// ACCESIBILIDAD: WCAG 2.1 nivel AA
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/habits/providers/habit_provider.dart';
import 'features/statistics/providers/statistics_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/leaderboard/providers/leaderboard_provider.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/notification_service.dart';

// =============================================================================
// PUNTO DE ENTRADA
// =============================================================================

/// Inicializa Flutter y monta la aplicación.
///
/// La función [main] es `async` para:
///   1. Garantizar que los bindings de Flutter estén listos antes de acceder
///      a APIs de plataforma como [SharedPreferences].
///   2. Pre-cargar [SharedPreferences] una sola vez y compartirlo como
///      singleton a través de [StorageService].
///   3. Configurar la orientación bloqueada (portrait) para UX consistente.
Future<void> main() async {
  // Garantiza que el motor de Flutter esté inicializado antes de llamar
  // cualquier método de plataforma (SharedPreferences, SystemChrome, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquea la app en modo retrato (portrait) para una experiencia coherente.
  // Los hábitos y estadísticas están diseñados para orientación vertical.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa SharedPreferences una sola vez al arrancar la app.
  // StorageService encapsula todas las operaciones de persistencia y
  // garantiza un acceso seguro y centralizado al almacenamiento local.
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // Lee la preferencia de modo oscuro antes de arrancar para que la barra
  // de estado tenga el estilo correcto desde el primer frame.
  final settingsData = storageService.readSettings();
  final isDarkMode = (settingsData['isDarkMode'] as bool?) ?? false;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          isDarkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          isDarkMode ? const Color(0xFF111D1A) : const Color(0xFFFAFDFC),
      systemNavigationBarIconBrightness:
          isDarkMode ? Brightness.light : Brightness.dark,
    ),
  );

  // Inicializa el servicio de notificaciones (timezone + plugin)
  await NotificationService.instance.init();

  // Monta la aplicación con el árbol de providers inyectado.
  runApp(
    _AppProviders(
      storageService: storageService,
      notificationService: NotificationService.instance,
      child: const EcoHabitApp(),
    ),
  );
}

// =============================================================================
// ÁRBOL DE PROVIDERS
// =============================================================================

/// Widget raíz que inyecta todos los providers de estado de la aplicación.
///
/// Usar [MultiProvider] en lugar de providers anidados mejora la legibilidad
/// y el rendimiento al evitar rebuilds en cascada innecesarios.
///
/// Orden de declaración:
///   1. [StorageService] — sin estado propio, disponible para todos
///   2. [HabitProvider]  — lógica de hábitos (depende de StorageService)
///   3. [StatisticsProvider] — cálculos de impacto (depende de HabitProvider)
///   4. [ProfileProvider] — perfil y logros del usuario
///   5. [SettingsProvider] — preferencias de la app
class _AppProviders extends StatelessWidget {
  const _AppProviders({
    required this.storageService,
    required this.notificationService,
    required this.child,
  });

  final StorageService storageService;
  final NotificationService notificationService;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // StorageService como Provider simple (no cambia en el tiempo)
        Provider<StorageService>.value(value: storageService),

        // HabitProvider — gestiona el CRUD de hábitos y el marcado diario.
        // Usa lazy: false para que cargue datos al inicio (no on-demand),
        // evitando flashes de contenido vacío en HomeScreen.
        ChangeNotifierProvider<HabitProvider>(
          create: (context) => HabitProvider(
            storageService: context.read<StorageService>(),
          )..loadHabits(), // Carga asíncrona inmediata al montar
          lazy: false,
        ),

        // StatisticsProvider — calcula métricas de impacto ambiental.
        // Depende de HabitProvider para leer el histórico de completados.
        ChangeNotifierProxyProvider<HabitProvider, StatisticsProvider>(
          create: (context) => StatisticsProvider(
            storageService: context.read<StorageService>(),
          ),
          update: (context, habitProvider, statisticsProvider) {
            statisticsProvider?.updateFromHabits(habitProvider.habits);
            return statisticsProvider ??
                StatisticsProvider(
                  storageService: context.read<StorageService>(),
                );
          },
        ),

        // ProfileProvider — nombre, avatar y logros del usuario.
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(
            storageService: context.read<StorageService>(),
          )..loadProfile(),
          lazy: false,
        ),

        // SettingsProvider — preferencias: notificaciones, tema, idioma.
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(
            storageService: context.read<StorageService>(),
            notificationService: notificationService,
          )..loadSettings(),
          lazy: false,
        ),

        // LeaderboardProvider — ranking global de rachas.
        ChangeNotifierProvider<LeaderboardProvider>(
          create: (_) => LeaderboardProvider(),
        ),
      ],
      child: child,
    );
  }
}
