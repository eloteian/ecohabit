// =============================================================================
// welcome_screen.dart — Pantalla de Bienvenida con Morfismo Premium
// =============================================================================
// Fondo claro (degradado menta muy suave → blanco) con logotipo verde y
// texto oscuro. El panel blanco inferior se expande al presionar "Continuar".
//
// CAMBIOS DE DISEÑO v2:
//   · Fondo: degradado claro (#E8F5EE → #F0F7F4) — legible con texto oscuro
//   · Logo: contenedor verde sólido (AppColors.primary) con icono blanco
//   · Texto: AppColors.textPrimary (oscuro) — contraste WCAG AAA
//   · Panel expandido: 62% del alto de pantalla (menos invasivo)
//   · Opciones: padding superior 32px para bajarlas dentro del panel
//   · Navegación: push con slide-up → UserSetupScreen (funcional)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import 'user_setup_screen.dart';

// =============================================================================
// CONSTANTES
// =============================================================================

const double _kPanelButtonHeight = 92.0;
const Duration _kHeaderDuration   = Duration(milliseconds: 500);
const Duration _kPanelDuration    = Duration(milliseconds: 680);
const Duration _kOptionsDelay     = Duration(milliseconds: 380);
const Duration _kOptionsDuration  = Duration(milliseconds: 820);

// =============================================================================
// WIDGET RAÍZ
// =============================================================================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// =============================================================================
// STATE
// =============================================================================

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  bool _isExpanded = false;
  bool _isNavigating = false;

  late final AnimationController _optionsController;

  // Animaciones por botón (fade + slide escalonado)
  late final Animation<double> _btn1Fade,  _btn2Fade,  _btn3Fade,  _signInFade;
  late final Animation<Offset> _btn1Slide, _btn2Slide, _btn3Slide, _signInSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void dispose() {
    _optionsController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // INICIALIZACIÓN
  // ---------------------------------------------------------------------------

  void _initAnimations() {
    _optionsController = AnimationController(
      vsync: this,
      duration: _kOptionsDuration,
    );

    _btn1Fade  = _fade(0.00, 0.42);  _btn1Slide  = _slide(0.00, 0.42);
    _btn2Fade  = _fade(0.18, 0.58);  _btn2Slide  = _slide(0.18, 0.58);
    _btn3Fade  = _fade(0.36, 0.75);  _btn3Slide  = _slide(0.36, 0.75);
    _signInFade = _fade(0.58, 1.00); _signInSlide = _slide(0.58, 1.00);
  }

  Animation<double> _fade(double a, double b) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _optionsController,
            curve: Interval(a, b, curve: Curves.easeOut)));

  Animation<Offset> _slide(double a, double b) =>
      Tween<Offset>(begin: const Offset(0, 0.55), end: Offset.zero).animate(
        CurvedAnimation(parent: _optionsController,
            curve: Interval(a, b, curve: Curves.easeOutCubic)));

  // ---------------------------------------------------------------------------
  // HANDLERS
  // ---------------------------------------------------------------------------

  Future<void> _onContinuePressed() async {
    if (_isExpanded) return;
    await HapticFeedback.lightImpact();
    setState(() => _isExpanded = true);
    await Future.delayed(_kOptionsDelay);
    if (mounted) _optionsController.forward();
  }

  Future<void> _navigateToSetup(String method) async {
    if (_isNavigating) return;
    _isNavigating = true;
    await HapticFeedback.mediumImpact();

    if (!mounted) return;

    // Slide-up transition — continúa la metáfora del panel expandiéndose
    await Navigator.push<void>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => UserSetupScreen(loginMethod: method),
        transitionsBuilder: (_, anim, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutQuart));
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: anim,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: fade, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 520),
      ),
    );

    // Si el usuario vuelve atrás desde UserSetupScreen, reinicia el panel
    if (mounted) {
      _isNavigating = false;
      setState(() => _isExpanded = false);
      _optionsController.reset();
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size        = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.paddingOf(context);

    final double panelExpanded = size.height * 0.62;
    final double panelButton   = _kPanelButtonHeight + safePadding.bottom;
    final double topInitial    = size.height * 0.18;
    final double topExpanded   = safePadding.top + 48.0;
    final double panelRadius   = _isExpanded ? 32.0 : 22.0;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5EE),
      body: Stack(
        children: [
          // Fondo — gradiente claro, siempre visible
          const _LightBackground(),

          // Columna principal
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Espaciador: colapsa cuando el panel sube
              AnimatedContainer(
                duration: _kHeaderDuration,
                curve: Curves.easeOutCubic,
                height: _isExpanded ? topExpanded : topInitial,
              ),

              // Logo verde
              const _GreenLogo(),

              const SizedBox(height: 24),

              // Título — crossfade entre bienvenida e iniciar sesión
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 360),
                firstCurve:  Curves.easeOut,
                secondCurve: Curves.easeIn,
                sizeCurve:   Curves.easeInOut,
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild:  const _WelcomeHeading(),
                secondChild: const _LoginHeading(),
              ),

              // Espacio flexible — absorbe el delta de altura del panel
              const Expanded(child: SizedBox.shrink()),

              // Panel inferior — morfismo botón → hoja de opciones
              AnimatedContainer(
                duration: _kPanelDuration,
                curve: Curves.easeOutQuart,
                width: double.infinity,
                height: _isExpanded ? panelExpanded : panelButton,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(panelRadius)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isExpanded ? 0.10 : 0.05),
                      blurRadius: _isExpanded ? 40 : 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(panelRadius)),
                  child: Stack(
                    children: [

                      // Botón "Continuar" — desaparece al expandir
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: _isExpanded ? 0.0 : 1.0,
                        child: IgnorePointer(
                          ignoring: _isExpanded,
                          child: _ContinueButton(
                            onPressed: _onContinuePressed,
                            bottomPadding: safePadding.bottom,
                          ),
                        ),
                      ),

                      // Opciones de login — aparecen con stagger
                      if (_isExpanded)
                        _LoginOptionsPanel(
                          btn1Fade: _btn1Fade,   btn1Slide: _btn1Slide,
                          btn2Fade: _btn2Fade,   btn2Slide: _btn2Slide,
                          btn3Fade: _btn3Fade,   btn3Slide: _btn3Slide,
                          signInFade: _signInFade, signInSlide: _signInSlide,
                          onApple:      () => _navigateToSetup('apple'),
                          onGoogle:     () => _navigateToSetup('google'),
                          onEmailReg:   () => _navigateToSetup('email'),
                          onEmailLogin: () => _navigateToSetup('email_login'),
                          bottomPadding: safePadding.bottom,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBWIDGETS ESTÁTICOS
// =============================================================================

// --- Fondo -------------------------------------------------------------------

class _LightBackground extends StatelessWidget {
  const _LightBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD6EEE3), // menta suave
            Color(0xFFEDF7F2), // casi blanco verdoso
            Color(0xFFF4FAF7), // blanco con toque verde
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

// --- Logo verde --------------------------------------------------------------

class _GreenLogo extends StatelessWidget {
  const _GreenLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.primary,           // Verde sólido de marca
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.eco_rounded, size: 52, color: Colors.white),
      ),
    );
  }
}

// --- Títulos -----------------------------------------------------------------

class _WelcomeHeading extends StatelessWidget {
  const _WelcomeHeading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bienvenido a EcoHabit',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: AppColors.textPrimary, // NEGRO — contraste total
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu compañero para un estilo de vida sostenible',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHeading extends StatelessWidget {
  const _LoginHeading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Comenzar ahora',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige cómo quieres continuar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PANEL INFERIOR — BOTÓN Y OPCIONES
// =============================================================================

// --- Botón inicial -----------------------------------------------------------

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.onPressed,
    required this.bottomPadding,
  });

  final VoidCallback onPressed;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.screenPadding, AppSizes.md,
        AppSizes.screenPadding, AppSizes.md + bottomPadding,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          ),
          child: const Text('Continuar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// --- Panel de opciones -------------------------------------------------------

class _LoginOptionsPanel extends StatelessWidget {
  const _LoginOptionsPanel({
    required this.btn1Fade,  required this.btn1Slide,
    required this.btn2Fade,  required this.btn2Slide,
    required this.btn3Fade,  required this.btn3Slide,
    required this.signInFade, required this.signInSlide,
    required this.onApple,
    required this.onGoogle,
    required this.onEmailReg,
    required this.onEmailLogin,
    required this.bottomPadding,
  });

  final Animation<double> btn1Fade,  btn2Fade,  btn3Fade,  signInFade;
  final Animation<Offset>  btn1Slide, btn2Slide, btn3Slide, signInSlide;
  final VoidCallback onApple, onGoogle, onEmailReg, onEmailLogin;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        32,                               // espacio top suficiente
        AppSizes.screenPadding,
        20 + bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle visual
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Header del panel
          const _PanelHeader(),

          const SizedBox(height: 22),

          // Apple
          _StaggerBtn(
            fade: btn1Fade, slide: btn1Slide,
            child: _SocialBtn(
              label: 'Continuar con Apple',
              onPressed: onApple,
              bg: const Color(0xFF1A1A1A),
              fg: Colors.white,
              border: Colors.transparent,
              icon: const Icon(Icons.apple, size: 22, color: Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          // Google
          _StaggerBtn(
            fade: btn2Fade, slide: btn2Slide,
            child: _SocialBtn(
              label: 'Continuar con Google',
              onPressed: onGoogle,
              bg: Colors.white,
              fg: const Color(0xFF3C4043),
              border: const Color(0xFFDDDDDD),
              icon: const _GoogleG(),
            ),
          ),

          const SizedBox(height: 10),

          // Email registro
          _StaggerBtn(
            fade: btn3Fade, slide: btn3Slide,
            child: _SocialBtn(
              label: 'Registrarse con correo',
              onPressed: onEmailReg,
              bg: AppColors.primarySurface,
              fg: AppColors.primaryDark,
              border: Colors.transparent,
              icon: const Icon(Icons.mail_outline_rounded,
                  size: 20, color: AppColors.primaryDark),
            ),
          ),

          const Spacer(),

          // Divisor
          _StaggerBtn(
            fade: signInFade, slide: signInSlide,
            child: Row(children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('¿ya tienes cuenta?',
                    style: Theme.of(context).textTheme.labelSmall),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ]),
          ),

          const SizedBox(height: 10),

          // Iniciar sesión con correo
          _StaggerBtn(
            fade: signInFade, slide: signInSlide,
            child: TextButton(
              onPressed: onEmailLogin,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                  children: [
                    const TextSpan(text: 'Iniciar sesión con correo  '),
                    TextSpan(
                      text: 'Entrar →',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
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

// --- Encabezado del panel ----------------------------------------------------

class _PanelHeader extends StatelessWidget {
  const _PanelHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Iniciar sesión',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(letterSpacing: -0.4)),
        const SizedBox(height: 3),
        Text('Elige tu método preferido',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

// --- Wrapper de animación por botón ------------------------------------------

class _StaggerBtn extends StatelessWidget {
  const _StaggerBtn({
    required this.fade,
    required this.slide,
    required this.child,
  });

  final Animation<double> fade;
  final Animation<Offset>  slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// --- Botón social genérico ---------------------------------------------------

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({
    required this.label,
    required this.onPressed,
    required this.bg,
    required this.fg,
    required this.border,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color bg, fg, border;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: AppSizes.buttonHeight,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            side: BorderSide(color: border, width: 1.2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            elevation: 0,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(alignment: Alignment.centerLeft, child: icon),
              Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Ícono Google G ----------------------------------------------------------

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22, height: 22,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue   = Color(0xFF4285F4);
  static const _red    = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green  = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final c  = Offset(size.width / 2, size.height / 2);
    final r  = size.width / 2;
    final sw = size.width * 0.22;
    final rect = Rect.fromCircle(center: c, radius: r - sw / 2);
    const pi = 3.14159265;
    const d  = pi / 180;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    arc.color = _blue;   canvas.drawArc(rect, -90 * d,  90 * d, false, arc);
    arc.color = _red;    canvas.drawArc(rect, 180 * d,  90 * d, false, arc);
    arc.color = _yellow; canvas.drawArc(rect,  90 * d,  90 * d, false, arc);
    arc.color = _green;  canvas.drawArc(rect,   0 * d,  90 * d, false, arc);

    // Trazo horizontal interior de la G
    final bar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw * 0.82
      ..color = _blue
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(c.dx, c.dy - sw * 0.18),
      Offset(size.width - sw * 0.3, c.dy - sw * 0.18),
      bar,
    );
  }

  @override
  bool shouldRepaint(_GoogleGPainter _) => false;
}
