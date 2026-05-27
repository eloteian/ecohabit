// =============================================================================
// eco_theme_colors.dart — Colores semánticos adaptativos (claro / oscuro)
// =============================================================================
// Los colores de MARCA (primary, energy, water, etc.) viven en AppColors y
// no cambian entre temas. Solo los colores de SUPERFICIE y TEXTO son adaptativos.
// =============================================================================

import 'package:flutter/material.dart';
import '../features/habits/models/habit_model.dart';

@immutable
class EcoThemeColors extends ThemeExtension<EcoThemeColors> {
  const EcoThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceGray,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.navBackground,
    required this.primarySurface,
    required this.isDark,
  });

  final Color background;
  final Color surface;
  final Color surfaceGray;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color navBackground;
  final Color primarySurface;
  final bool isDark;

  /// Fondo de la tarjeta de hábito completado (adapta surfaceColor del modelo).
  Color categoryBackground(HabitCategory category) =>
      isDark ? category.color.withValues(alpha: 0.15) : category.surfaceColor;

  // ── Tema claro ───────────────────────────────────────────────────────────
  static const light = EcoThemeColors(
    background:    Color(0xFFF8FAF9),
    surface:       Color(0xFFFFFFFF),
    surfaceGray:   Color(0xFFF2F7F5),
    textPrimary:   Color(0xFF1C2B2A),
    textSecondary: Color(0xFF4A5E58),
    textTertiary:  Color(0xFF8A9E97),
    border:        Color(0xFFDDE8E4),
    navBackground: Color(0xFFFAFDFC),
    primarySurface: Color(0xFFDFF2E9),
    isDark: false,
  );

  // ── Tema oscuro ──────────────────────────────────────────────────────────
  static const dark = EcoThemeColors(
    background:    Color(0xFF0F1A17),
    surface:       Color(0xFF172421),
    surfaceGray:   Color(0xFF1C2B26),
    textPrimary:   Color(0xFFE8F0EC),
    textSecondary: Color(0xFF96B4A8),
    textTertiary:  Color(0xFF567A6E),
    border:        Color(0xFF253630),
    navBackground: Color(0xFF111D1A),
    primarySurface: Color(0xFF162B22),
    isDark: true,
  );

  @override
  EcoThemeColors copyWith({
    Color? background, Color? surface, Color? surfaceGray,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? border, Color? navBackground, Color? primarySurface, bool? isDark,
  }) => EcoThemeColors(
    background:    background    ?? this.background,
    surface:       surface       ?? this.surface,
    surfaceGray:   surfaceGray   ?? this.surfaceGray,
    textPrimary:   textPrimary   ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary:  textTertiary  ?? this.textTertiary,
    border:        border        ?? this.border,
    navBackground: navBackground ?? this.navBackground,
    primarySurface: primarySurface ?? this.primarySurface,
    isDark:        isDark        ?? this.isDark,
  );

  @override
  EcoThemeColors lerp(EcoThemeColors? other, double t) {
    if (other == null) return this;
    return EcoThemeColors(
      background:    Color.lerp(background,    other.background,    t)!,
      surface:       Color.lerp(surface,       other.surface,       t)!,
      surfaceGray:   Color.lerp(surfaceGray,   other.surfaceGray,   t)!,
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary:  Color.lerp(textTertiary,  other.textTertiary,  t)!,
      border:        Color.lerp(border,        other.border,        t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      isDark: t > 0.5 ? other.isDark : isDark,
    );
  }
}

/// Acceso rápido: `context.colors.surface`, `context.colors.textPrimary`, etc.
extension EcoThemeColorsX on BuildContext {
  EcoThemeColors get colors =>
      Theme.of(this).extension<EcoThemeColors>() ?? EcoThemeColors.light;
}
