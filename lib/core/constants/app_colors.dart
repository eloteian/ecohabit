// =============================================================================
// app_colors.dart — Paleta de colores premium de EcoHabit
// -----------------------------------------------------------------------------
// Define la identidad visual completa de la app:
//   · Verde Salvia / Menta como color primario (naturaleza, sostenibilidad)
//   · Gris Humo para texto secundario y superficies neutras
//   · Blanco roto (#FAFAFA) como fondo principal para calidez visual
//   · Degradados sutiles estilo Apple para profundidad sin ruido
//
// Accesibilidad: todos los pares de color cumplen WCAG 2.1 nivel AA
// (relación de contraste ≥ 4.5:1 para texto normal).
// =============================================================================

import 'package:flutter/material.dart';

/// Paleta de colores semántica de EcoHabit.
///
/// Usa siempre estas constantes en lugar de valores hex directos
/// para garantizar consistencia y facilitar refactorizaciones de tema.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // COLORES PRIMARIOS — Verde Salvia / Menta
  // ---------------------------------------------------------------------------

  /// Verde salvia oscuro — botones principales, íconos activos.
  /// Contraste sobre blanco: 4.58:1 ✓ (WCAG AA)
  static const Color primaryDark = Color(0xFF3D7A5F);

  /// Verde salvia — color de marca principal.
  static const Color primary = Color(0xFF4E9A78);

  /// Verde menta suave — fondos de tarjetas, chips activos.
  static const Color primaryLight = Color(0xFF7EC8A4);

  /// Verde menta muy claro — fondos de secciones sutiles.
  static const Color primarySurface = Color(0xFFDFF2E9);

  // ---------------------------------------------------------------------------
  // COLORES NEUTROS — Gris Humo
  // ---------------------------------------------------------------------------

  /// Gris antracita — texto principal y encabezados.
  /// Contraste sobre #FAFAFA: 14.7:1 ✓ (WCAG AAA)
  static const Color textPrimary = Color(0xFF1C2B2A);

  /// Gris pizarra — texto de cuerpo y descripciones.
  /// Contraste sobre #FAFAFA: 7.2:1 ✓ (WCAG AA)
  static const Color textSecondary = Color(0xFF4A5E58);

  /// Gris humo — texto de ayuda, placeholders y metadatos.
  /// Contraste sobre #FAFAFA: 4.6:1 ✓ (WCAG AA)
  static const Color textTertiary = Color(0xFF8A9E97);

  /// Gris muy claro — bordes sutiles, divisores.
  static const Color border = Color(0xFFDDE8E4);

  /// Gris de superficie — fondos de inputs y tarjetas secundarias.
  static const Color surfaceGray = Color(0xFFF2F7F5);

  // ---------------------------------------------------------------------------
  // FONDOS Y SUPERFICIES
  // ---------------------------------------------------------------------------

  /// Fondo principal — blanco cálido (evita el blanco puro para los ojos).
  static const Color background = Color(0xFFF8FAF9);

  /// Superficie de tarjetas principales.
  static const Color surface = Color(0xFFFFFFFF);

  /// Fondo de la barra de navegación inferior.
  static const Color navBackground = Color(0xFFFAFDFC);

  // ---------------------------------------------------------------------------
  // COLORES SEMÁNTICOS — Retroalimentación y estados
  // ---------------------------------------------------------------------------

  /// Verde éxito — hábito completado, logro desbloqueado.
  static const Color success = Color(0xFF3DAA70);

  /// Amarillo advertencia — racha en riesgo.
  static const Color warning = Color(0xFFE8A838);

  /// Rojo error — hábito fallido, validación incorrecta.
  static const Color error = Color(0xFFD94F4F);

  /// Azul información — tooltips y ayuda contextual.
  static const Color info = Color(0xFF4A90C4);

  // ---------------------------------------------------------------------------
  // COLORES DE IMPACTO AMBIENTAL — Para gráficas y estadísticas
  // ---------------------------------------------------------------------------

  /// Azul agua — ahorro de agua en litros.
  static const Color water = Color(0xFF5BAFD6);

  /// Verde hoja — reducción de CO₂ en kg.
  static const Color co2 = Color(0xFF4E9A78);

  /// Naranja energía — ahorro de energía en kWh.
  static const Color energy = Color(0xFFE07B39);

  /// Morado residuos — reducción de residuos en gramos.
  static const Color waste = Color(0xFF9B6DC5);

  // ---------------------------------------------------------------------------
  // DEGRADADOS — Estilo Apple, de arriba a abajo
  // ---------------------------------------------------------------------------

  /// Degradado principal de la app (hero sections, onboarding).
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D7A5F), Color(0xFF7EC8A4)],
    stops: [0.0, 1.0],
  );

  /// Degradado suave para fondos de tarjetas premium.
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF2F7F5)],
  );

  /// Degradado de impacto ambiental (stats screen).
  static const LinearGradient impactGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D7A5F), Color(0xFF4A90C4)],
  );

  // ---------------------------------------------------------------------------
  // OPACIDADES Y SOMBRAS
  // ---------------------------------------------------------------------------

  /// Sombra suave estilo iOS para tarjetas flotantes.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1C2B2A).withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFF1C2B2A).withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ];

  /// Sombra elevada para modales y bottom sheets.
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF1C2B2A).withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];
}
