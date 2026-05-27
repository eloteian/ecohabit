// =============================================================================
// splash_screen.dart — SplashScreen Ultra Premium de EcoHabit
// =============================================================================
// Implementa un sistema de animaciones coordinadas (Staggered Animation)
// de alta fidelidad optimizado para 60 FPS.
//
// ARQUITECTURA DE ANIMACIONES (4 controladores independientes):
// ┌──────────────────────────────────────────────────────────────────┐
// │ Timeline total: ~3 400 ms desde initState hasta navegación       │
// │                                                                  │
// │  0 ms ──► _bgController   (800ms)  Fondo: gradiente fade-in     │
// │  300ms ──► _leafController (1400ms) Isotipo: tornado + elasticOut│
// │  1500ms ──► _textController (900ms)  Texto: slide-up + fade     │
// │  2100ms ──► _glowController (2000ms) Pulso de luz (repeat)      │
// │  3400ms ──► navigate()                                           │
// └──────────────────────────────────────────────────────────────────┘
//
// RENDIMIENTO:
//   · TickerProviderStateMixin para múltiples vsync independientes
//   · Dedicated transition widgets (SlideTransition, ScaleTransition,
//     RotationTransition, FadeTransition) — usan el Compositor de
//     Flutter directamente, sin invocar build() en cada frame
//   · AnimatedBuilder solo para el efecto de glow (estado local mínimo)
//   · RepaintBoundary alrededor del isotipo y el bloque de texto
//   · Todos los widgets estáticos son const
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../shared/services/storage_service.dart';

// =============================================================================
// WIDGET RAÍZ (StatefulWidget)
// =============================================================================

/// Pantalla de carga animada de EcoHabit.
///
/// Verifica el estado de onboarding en [StorageService] y redirige
/// a `/onboarding` o `/home` al finalizar la secuencia de animación.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// =============================================================================
// STATE — TickerProviderStateMixin para múltiples controladores
// =============================================================================

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ---------------------------------------------------------------------------
  // CONTROLADORES DE ANIMACIÓN
  // Cada controlador maneja un stage visual independiente para que
  // los Intervals sean relativos a su propia duración, no al total.
  // ---------------------------------------------------------------------------

  /// Stage 1: Gradiente de fondo (fade-in inicial).
  late final AnimationController _bgController;

  /// Stage 2: Isotipo/hoja (tornado de entrada + elasticOut).
  late final AnimationController _leafController;

  /// Stage 3: Bloque de texto (slide-up escalonado + fade).
  late final AnimationController _textController;

  /// Stage 4: Pulso de luz (breathing glow, se repite infinitamente).
  late final AnimationController _glowController;

  // ---------------------------------------------------------------------------
  // ANIMACIONES — FONDO
  // ---------------------------------------------------------------------------

  /// Opacidad del gradiente: 0.0 → 1.0 con Curves.easeIn.
  late final Animation<double> _bgOpacityAnim;

  /// Escala del círculo decorativo superior-derecho (efecto parallax sutil).
  late final Animation<double> _bgCircleScaleAnim;

  // ---------------------------------------------------------------------------
  // ANIMACIONES — ISOTIPO (HOJA)
  //
  // El efecto "tornado desde la derecha" se consigue combinando tres
  // animaciones independientes sobre el mismo widget, cada una con su
  // propio Interval y curva:
  //
  //   · _leafEntryAnim : SlideTransition  → mueve de derecha a centro
  //   · _leafTurnsAnim : RotationTransition → deceleración rotacional
  //   · _leafScaleAnim : ScaleTransition  → crece con rebote elástico
  // ---------------------------------------------------------------------------

  /// Desplazamiento horizontal: Offset(2.5, 0) → Offset.zero.
  /// Interval 0.0-0.80 con easeOutCubic (deceleración rápida).
  late final Animation<Offset> _leafEntryAnim;

  /// Rotación de tornado: 2.25 turns → 0.0 turns.
  /// 2.25 * 360° = 810° de rotación acumulada visible al entrar.
  late final Animation<double> _leafTurnsAnim;

  /// Escala: 0.0 → 1.0 con Curves.elasticOut para el rebote premium.
  /// Empieza en Interval 0.05 para que la hoja sea invisible durante
  /// los primeros frames del viaje (aparece "de la nada").
  late final Animation<double> _leafScaleAnim;

  // ---------------------------------------------------------------------------
  // ANIMACIONES — TEXTO
  // ---------------------------------------------------------------------------

  /// Slide + fade del título "EcoHabit".
  /// Interval 0.0-0.70 de _textController con Curves.easeOutQuart.
  late final Animation<Offset> _titleSlideAnim;
  late final Animation<double> _titleFadeAnim;

  /// Slide + fade del tagline (staggered 120ms después del título).
  /// Interval 0.15-0.85 de _textController.
  late final Animation<Offset> _taglineSlideAnim;
  late final Animation<double> _taglineFadeAnim;

  // ---------------------------------------------------------------------------
  // ANIMACIONES — GLOW (pulso de luz)
  // ---------------------------------------------------------------------------

  /// Intensidad del halo luminoso del isotipo: 0.0 ↔ 1.0, repeat con reverse.
  late final Animation<double> _glowIntensityAnim;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _startSequence();
  }

  @override
  void dispose() {
    // Siempre liberar controladores en dispose para evitar memory leaks.
    _bgController.dispose();
    _leafController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // INICIALIZACIÓN DE CONTROLADORES
  // ---------------------------------------------------------------------------

  void _initControllers() {
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  // ---------------------------------------------------------------------------
  // INICIALIZACIÓN DE ANIMACIONES
  // ---------------------------------------------------------------------------

  void _initAnimations() {
    _initBackgroundAnimations();
    _initLeafAnimations();
    _initTextAnimations();
    _initGlowAnimation();
  }

  void _initBackgroundAnimations() {
    _bgOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: Curves.easeIn,
      ),
    );

    _bgCircleScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _initLeafAnimations() {
    // --- Posición: tornado desde la derecha hacia el centro ----------------
    // Offset(2.5, 0) = 2.5 veces el ancho del widget hacia la derecha.
    // El Interval 0.0-0.80 hace que la hoja llegue antes de que el
    // controlador termine, dejando el 20% final para que el elasticOut
    // del scale tenga espacio de sobre-rebotar visualmente.
    _leafEntryAnim = Tween<Offset>(
      begin: const Offset(2.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _leafController,
        curve: const Interval(0.0, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    // --- Rotación: 2.25 turns → 0.0 turns ---------------------------------
    // 2.25 turns = 810° de rotación acumulada. Empieza en 90° de offset
    // visual (0.25 turns extra) lo que rompe la simetría y hace el inicio
    // del giro más dramático.
    // Se desacelera con easeOutCubic sincronizado con el desplazamiento.
    _leafTurnsAnim = Tween<double>(begin: 2.25, end: 0.0).animate(
      CurvedAnimation(
        parent: _leafController,
        curve: const Interval(0.0, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    // --- Escala: 0.0 → 1.0 con elasticOut (rebote elegante) ---------------
    // El Interval 0.05-0.90 retrasa el inicio levemente para que la hoja
    // "emerja" de la nada cuando ya está en movimiento desde la derecha,
    // y usa el tramo 0.75-0.90 para el overshoot del elasticOut.
    _leafScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _leafController,
        curve: const Interval(0.05, 0.90, curve: Curves.elasticOut),
      ),
    );
  }

  void _initTextAnimations() {
    // --- Título "EcoHabit" ------------------------------------------------
    // Slide desde Offset(0, 0.8) — el valor 0.8 representa 80% de la
    // altura del widget hacia abajo, suficiente para que emerja de "debajo"
    // sin ser exagerado.
    _titleSlideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        // Interval 0.0-0.72 + easeOutQuart: arranque rápido,
        // desaceleración suave para una entrada con carácter.
        curve: const Interval(0.0, 0.72, curve: Curves.easeOutQuart),
      ),
    );

    _titleFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    // --- Tagline (staggered: empieza 15% después del título) ---------------
    _taglineSlideAnim = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.15, 0.88, curve: Curves.easeOutQuart),
      ),
    );

    _taglineFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.15, 0.70, curve: Curves.easeOut),
      ),
    );
  }

  void _initGlowAnimation() {
    _glowIntensityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        // easeInOut para que el pulso de luz se sienta orgánico,
        // no mecánico.
        curve: Curves.easeInOut,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECUENCIA COORDINADA (STAGGERED)
  // ---------------------------------------------------------------------------

  /// Orquesta el inicio de cada controlador según el timeline definido.
  ///
  /// Usa [Future.delayed] en lugar de listeners para un código más
  /// legible. Los guards `if (!mounted)` previenen setState sobre
  /// widgets ya desmontados (seguridad contra race conditions).
  Future<void> _startSequence() async {
    // Stage 1: Fondo — inmediato
    _bgController.forward();

    // Stage 2: Hoja — 300ms después (el fondo ya es visible al 37%)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _leafController.forward();

    // Stage 3: Texto — cuando la hoja ha llegado al centro (~80% del
    // _leafController = 1120ms). Añadimos 80ms de pausa intencional
    // para que el ojo registre la hoja antes de que aparezca el texto.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _textController.forward();

    // Stage 4: Glow — 600ms después de que el texto inicia su entrada
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _glowController.repeat(reverse: true);

    // Navegación — después de que el usuario ha visto el logo completo
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _navigateNext();
  }

  /// Decide la ruta destino y ejecuta la transición.
  void _navigateNext() {
    final storage = context.read<StorageService>();
    final destination = storage.isOnboardingDone
        ? AppRoutes.home
        : AppRoutes.onboarding;
    Navigator.pushReplacementNamed(context, destination);
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Gradiente animado de fondo
          _SplashBackground(
            opacityAnim: _bgOpacityAnim,
            circleScaleAnim: _bgCircleScaleAnim,
            screenSize: size,
          ),

          // Layer 2: Contenido central (isotipo + texto)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Isotipo con efecto tornado
                _LeafIsotipo(
                  entryAnim: _leafEntryAnim,
                  turnsAnim: _leafTurnsAnim,
                  scaleAnim: _leafScaleAnim,
                  glowAnim: _glowIntensityAnim,
                ),

                const SizedBox(height: 32),

                // Bloque de texto escalonado
                _TextBlock(
                  titleSlideAnim: _titleSlideAnim,
                  titleFadeAnim: _titleFadeAnim,
                  taglineSlideAnim: _taglineSlideAnim,
                  taglineFadeAnim: _taglineFadeAnim,
                ),

                const SizedBox(height: 72),

                // Indicador de carga minimalista
                _LoadingDots(fadeAnim: _taglineFadeAnim),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBWIDGETS PRIVADOS — Cada uno es un const o gestiona solo su subtree
// =============================================================================

// -----------------------------------------------------------------------------
// FONDO ANIMADO
// -----------------------------------------------------------------------------

/// Fondo con gradiente que se desvanece suavemente al entrar.
///
/// Usa [FadeTransition] (composited layer) en lugar de [Opacity] dentro de
/// un [AnimatedBuilder] para evitar repaints del árbol completo.
class _SplashBackground extends StatelessWidget {
  const _SplashBackground({
    required this.opacityAnim,
    required this.circleScaleAnim,
    required this.screenSize,
  });

  final Animation<double> opacityAnim;
  final Animation<double> circleScaleAnim;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacityAnim,
      child: Stack(
        children: [
          // Gradiente principal — de arriba-izquierda a abajo-derecha
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E5C42), // verde bosque profundo
                  Color(0xFF2E7D5A), // verde salvia oscuro
                  Color(0xFF4E9A78), // verde salvia — color de marca
                  Color(0xFF6AB89A), // verde menta suave
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
              ),
            ),
          ),

          // Círculo decorativo superior-derecho (profundidad sutil)
          Positioned(
            top: -screenSize.width * 0.12,
            right: -screenSize.width * 0.12,
            child: ScaleTransition(
              scale: circleScaleAnim,
              child: _DecorativeCircle(
                size: screenSize.width * 0.62,
                opacity: 0.12,
                strokeWidth: 1.5,
              ),
            ),
          ),

          // Círculo decorativo interior (anidado para mayor riqueza)
          Positioned(
            top: screenSize.width * 0.02,
            right: screenSize.width * 0.02,
            child: ScaleTransition(
              scale: circleScaleAnim,
              child: _DecorativeCircle(
                size: screenSize.width * 0.36,
                opacity: 0.08,
                strokeWidth: 1.0,
              ),
            ),
          ),

          // Círculo decorativo inferior-izquierdo
          Positioned(
            bottom: -screenSize.width * 0.18,
            left: -screenSize.width * 0.18,
            child: _DecorativeCircle(
              size: screenSize.width * 0.72,
              opacity: 0.07,
              strokeWidth: 1.0,
            ),
          ),

          // Capa de brillo superior (efecto vidrioso premium)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.35,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x22FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo con borde translúcido para decoración de fondo.
class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    required this.opacity,
    required this.strokeWidth,
  });

  final double size;
  final double opacity;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: strokeWidth,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ISOTIPO — HOJA CON EFECTO TORNADO
// -----------------------------------------------------------------------------

/// Isotipo animado con entrada tipo tornado desde la derecha.
///
/// Las tres transformaciones (posición, rotación, escala) se aplican
/// como widgets Transition dedicados. Flutter los compone en una sola
/// capa en el Skia/Impeller compositor sin reconstruir el widget tree.
///
/// Orden de anidamiento (de afuera hacia adentro):
///   SlideTransition → desplazamiento horizontal
///   └── RotationTransition → rotación de tornado (decelerada)
///       └── ScaleTransition → crecimiento con elasticOut
///           └── RepaintBoundary → aisla el glow del resto del árbol
///               └── AnimatedBuilder → solo para el glow dinámico
class _LeafIsotipo extends StatelessWidget {
  const _LeafIsotipo({
    required this.entryAnim,
    required this.turnsAnim,
    required this.scaleAnim,
    required this.glowAnim,
  });

  final Animation<Offset> entryAnim;
  final Animation<double> turnsAnim;
  final Animation<double> scaleAnim;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: entryAnim,
      child: RotationTransition(
        turns: turnsAnim,
        child: ScaleTransition(
          scale: scaleAnim,
          // RepaintBoundary: el glow cambia en cada frame → aísla los
          // repaints para que no propaguen al árbol padre.
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: glowAnim,
              builder: (_, child) => _buildIsotipoWithGlow(child!),
              child: const _StaticLeafIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIsotipoWithGlow(Widget child) {
    // El radio y la opacidad del glow oscilan entre mínimo y máximo
    // para crear el efecto de "respiración" luminosa.
    final glowRadius = 24.0 + (glowAnim.value * 28.0);
    final glowOpacity = 0.18 + (glowAnim.value * 0.24);
    final innerOpacity = 0.12 + (glowAnim.value * 0.08);

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        // Fondo semitransparente con efecto cristal
        color: Colors.white.withValues(alpha: innerOpacity),
        borderRadius: BorderRadius.circular(34),
        // Borde sutil que acentúa la forma del isotipo
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          // Halo exterior (glow principal)
          BoxShadow(
            color: Colors.white.withValues(alpha: glowOpacity),
            blurRadius: glowRadius,
            spreadRadius: glowRadius * 0.25,
          ),
          // Sombra interior suave para profundidad
          BoxShadow(
            color: const Color(0xFF1E5C42).withValues(alpha: 0.30),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Ícono de hoja estático — const para que Flutter lo reutilice sin reconstruir.
class _StaticLeafIcon extends StatelessWidget {
  const _StaticLeafIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.eco_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BLOQUE DE TEXTO
// -----------------------------------------------------------------------------

/// Título y tagline con animaciones de slide-up escalonadas.
///
/// Usa [ClipRect] + [SlideTransition] en lugar de [Transform.translate]
/// para que el texto no sea visible fuera de sus límites durante la
/// entrada — el ClipRect recorta exactamente el área del widget.
class _TextBlock extends StatelessWidget {
  const _TextBlock({
    required this.titleSlideAnim,
    required this.titleFadeAnim,
    required this.taglineSlideAnim,
    required this.taglineFadeAnim,
  });

  final Animation<Offset> titleSlideAnim;
  final Animation<double> titleFadeAnim;
  final Animation<Offset> taglineSlideAnim;
  final Animation<double> taglineFadeAnim;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título principal con overflow clip
          ClipRect(
            child: SlideTransition(
              position: titleSlideAnim,
              child: FadeTransition(
                opacity: titleFadeAnim,
                child: const _TitleText(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Tagline (staggered)
          ClipRect(
            child: SlideTransition(
              position: taglineSlideAnim,
              child: FadeTransition(
                opacity: taglineFadeAnim,
                child: const _TaglineText(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto del nombre de la app — const para zero-rebuild overhead.
class _TitleText extends StatelessWidget {
  const _TitleText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'EcoHabit',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 44,
        fontWeight: FontWeight.w200,
        letterSpacing: -2.0,
        color: Colors.white,
        height: 1.0,
      ),
    );
  }
}

/// Tagline de la app — const para zero-rebuild overhead.
class _TaglineText extends StatelessWidget {
  const _TaglineText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hábitos para un planeta mejor',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.8,
        color: Colors.white.withValues(alpha: 0.72),
        height: 1.0,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INDICADOR DE CARGA
// -----------------------------------------------------------------------------

/// Tres puntos pulsantes que indican que la app está iniciando.
///
/// Usa [FadeTransition] reutilizando [_taglineFadeAnim] para que los
/// puntos aparezcan junto con el tagline sin necesidad de un controlador
/// adicional.
class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.fadeAnim});

  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _PulsingDot(delayFactor: index),
          );
        }),
      ),
    );
  }
}

/// Punto individual con animación de pulso usando TweenSequence.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.delayFactor});

  /// Factor de retraso (0, 1, 2) para el efecto escalonado entre los dots.
  final int delayFactor;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;
  late final Animation<double> _dotOpacityAnim;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // TweenSequence: aparece rápido, desaparece lento → sensación orgánica
    _dotOpacityAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.25)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_dotController);

    // Retraso escalonado: 0ms, 200ms, 400ms para la ola de puntos
    Future.delayed(Duration(milliseconds: widget.delayFactor * 200), () {
      if (mounted) _dotController.repeat();
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _dotOpacityAnim,
      child: Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
