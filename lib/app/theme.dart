// =============================================================================
// theme.dart — Temas visual premium de EcoHabit (claro y oscuro)
// -----------------------------------------------------------------------------
// Centraliza toda la configuración de Material 3 para garantizar consistencia
// visual. Usa Google Fonts (Inter) para tipografía de estilo Apple.
//
// Los colores adaptativos (superficie, texto, borde) se proveen a través de
// EcoThemeColors (ThemeExtension) — accesibles vía context.colors.
// Los colores de MARCA (primary, energy, water, etc.) no cambian con el tema.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import 'eco_theme_colors.dart';

/// Configuración del tema visual de EcoHabit.
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // TEMA CLARO PRINCIPAL
  // ---------------------------------------------------------------------------

  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySurface,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primarySurface,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.water,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFDCF0FA),
      onTertiaryContainer: const Color(0xFF1A4D6B),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFE8E8),
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceGray,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.border.withValues(alpha: 0.5),
      shadow: AppColors.textPrimary.withValues(alpha: 0.08),
      scrim: Colors.black.withValues(alpha: 0.3),
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.primaryLight,
    );

    final textTheme = GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
            height: 1.12),
        displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.25,
            color: AppColors.textPrimary,
            height: 1.16),
        displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            letterSpacing: 0,
            color: AppColors.textPrimary,
            height: 1.22),
        headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
            height: 1.25),
        headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
            color: AppColors.textPrimary,
            height: 1.29),
        headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: AppColors.textPrimary,
            height: 1.33),
        titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.15,
            color: AppColors.textPrimary,
            height: 1.27),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
            height: 1.5),
        titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
            height: 1.43),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
            color: AppColors.textPrimary,
            height: 1.5),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: AppColors.textSecondary,
            height: 1.43),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: AppColors.textTertiary,
            height: 1.33),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
            height: 1.43),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppColors.textSecondary,
            height: 1.33),
        labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppColors.textTertiary,
            height: 1.45),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.border,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.textPrimary),
        iconTheme: const IconThemeData(
            color: AppColors.textPrimary, size: AppSizes.iconMd),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          textStyle: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg, vertical: AppSizes.md),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          textStyle: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceGray,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary),
        hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary),
        errorStyle: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navBackground,
        indicatorColor: AppColors.primarySurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textTertiary,
            letterSpacing: 0.3,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? AppColors.primary : AppColors.textTertiary,
            size: AppSizes.navIconSize,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceGray,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.xs),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySurface;
          }
          return AppColors.border;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.border,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySurface,
        linearMinHeight: 6,
      ),
      extensions: const [EcoThemeColors.light],
    );
  }

  // ---------------------------------------------------------------------------
  // TEMA OSCURO
  // ---------------------------------------------------------------------------

  static ThemeData get dark {
    const c = EcoThemeColors.dark;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: c.primarySurface,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      secondaryContainer: c.primarySurface,
      onSecondaryContainer: AppColors.primaryLight,
      tertiary: AppColors.water,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF0D2D40),
      onTertiaryContainer: AppColors.water,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFF3B0A0A),
      onErrorContainer: AppColors.error,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceGray,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.border.withValues(alpha: 0.5),
      shadow: Colors.black.withValues(alpha: 0.4),
      scrim: Colors.black.withValues(alpha: 0.5),
      inverseSurface: c.textPrimary,
      onInverseSurface: c.background,
      inversePrimary: AppColors.primaryLight,
    );

    final textTheme = GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            color: c.textPrimary,
            height: 1.12),
        displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.25,
            color: c.textPrimary,
            height: 1.16),
        displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            letterSpacing: 0,
            color: c.textPrimary,
            height: 1.22),
        headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: c.textPrimary,
            height: 1.25),
        headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
            color: c.textPrimary,
            height: 1.29),
        headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: c.textPrimary,
            height: 1.33),
        titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.15,
            color: c.textPrimary,
            height: 1.27),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: c.textPrimary,
            height: 1.5),
        titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: c.textPrimary,
            height: 1.43),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
            color: c.textPrimary,
            height: 1.5),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: c.textSecondary,
            height: 1.43),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: c.textTertiary,
            height: 1.33),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: c.textPrimary,
            height: 1.43),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: c.textSecondary,
            height: 1.33),
        labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: c.textTertiary,
            height: 1.45),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.background,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: c.border,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: c.textPrimary),
        iconTheme: IconThemeData(color: c.textPrimary, size: AppSizes.iconMd),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: BorderSide(color: c.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          textStyle: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg, vertical: AppSizes.md),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          textStyle: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceGray,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: c.textSecondary),
        hintStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: c.textTertiary),
        errorStyle: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.navBackground,
        indicatorColor: c.primarySurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : c.textTertiary,
            letterSpacing: 0.3,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? AppColors.primary : c.textTertiary,
            size: AppSizes.navIconSize,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceGray,
        selectedColor: c.primarySurface,
        labelStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500, color: c.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
          side: BorderSide(color: c.border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.xs),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return c.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primarySurface;
          return c.border;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary,
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: c.background),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
        ),
        showDragHandle: true,
        dragHandleColor: c.border,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: c.primarySurface,
        linearMinHeight: 6,
      ),
      extensions: const [EcoThemeColors.dark],
    );
  }
}
