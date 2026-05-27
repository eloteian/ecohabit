// =============================================================================
// app_sizes.dart — Sistema de espaciado y tipometría de EcoHabit
// -----------------------------------------------------------------------------
// Implementa un sistema de 8-point grid (estándar de Material/Apple) para
// garantizar coherencia visual en todos los tamaños de pantalla.
// =============================================================================

/// Sistema de espaciado basado en múltiplos de 4pt.
abstract final class AppSizes {
  // ---------------------------------------------------------------------------
  // ESPACIADO (8-point grid system)
  // ---------------------------------------------------------------------------
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ---------------------------------------------------------------------------
  // RADIO DE BORDES
  // ---------------------------------------------------------------------------
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusCircle = 999.0;

  // ---------------------------------------------------------------------------
  // TAMAÑOS DE ÍCONOS
  // ---------------------------------------------------------------------------
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ---------------------------------------------------------------------------
  // COMPONENTES
  // ---------------------------------------------------------------------------

  /// Altura estándar de botones primarios.
  static const double buttonHeight = 52.0;

  /// Altura de inputs de formulario.
  static const double inputHeight = 56.0;

  /// Altura de la barra de navegación inferior.
  static const double navBarHeight = 80.0;

  /// Tamaño del ícono de la barra de navegación.
  static const double navIconSize = 26.0;

  /// Altura máxima de tarjetas de hábito.
  static const double habitCardHeight = 88.0;

  /// Padding horizontal global de la pantalla.
  static const double screenPadding = 20.0;
}
