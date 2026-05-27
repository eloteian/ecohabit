// =============================================================================
// user_setup_screen.dart — Configuración de Perfil Post-Login
// =============================================================================
// Pantalla funcional que recoge el nombre del usuario tras seleccionar
// un método de inicio de sesión. Persiste el perfil y navega al home.
//
// ANIMACIONES (un solo AnimationController, 1 100ms):
//   Interval 0.00-0.35 — logo entra con ScaleTransition + elasticOut
//   Interval 0.20-0.50 — título y subtítulo slide-up + fade
//   Interval 0.40-0.70 — selector de avatar slide-up + fade
//   Interval 0.55-0.85 — campo de nombre slide-up + fade
//   Interval 0.75-1.00 — botón CTA slide-up + fade
//
// SEGURIDAD:
//   · Validación de nombre en el formulario (mínimo 2 chars, sin caracteres
//     de control) — la sanitización final la hace StorageService.
//   · Form key y AutovalidateMode.onUserInteraction para UX reactiva.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../shared/services/storage_service.dart';

// =============================================================================
// CONSTANTES
// =============================================================================

/// Emojis disponibles como avatar de perfil.
const List<String> _kAvatars = ['🌱', '🌿', '🍃', '🌲', '♻️', '🌍'];

/// Expresión regular: sólo letras (incluyendo tildes y ñ) y espacios.
final RegExp _kNameRegExp =
    RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');

// =============================================================================
// WIDGET
// =============================================================================

/// Pantalla de configuración de perfil inicial.
///
/// [loginMethod] identifica el método usado ('apple', 'google',
/// 'email', 'email_login') para mostrarlo en el header y guardarlo.
class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key, required this.loginMethod});

  final String loginMethod;

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen>
    with SingleTickerProviderStateMixin {

  // ---------------------------------------------------------------------------
  // ANIMACIÓN ENTRADA
  // ---------------------------------------------------------------------------

  late final AnimationController _entranceCtrl;

  // Animaciones staggered por sección
  late final Animation<double> _logoScale, _logoFade;
  late final Animation<Offset>  _titleSlide;
  late final Animation<double>  _titleFade;
  late final Animation<Offset>  _avatarSlide;
  late final Animation<double>  _avatarFade;
  late final Animation<Offset>  _fieldSlide;
  late final Animation<double>  _fieldFade;
  late final Animation<Offset>  _btnSlide;
  late final Animation<double>  _btnFade;

  // ---------------------------------------------------------------------------
  // ESTADO DEL FORMULARIO
  // ---------------------------------------------------------------------------

  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _nameFocus  = FocusNode();

  String _selectedAvatar = '🌱';
  bool   _isSaving       = false;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ANIMACIONES
  // ---------------------------------------------------------------------------

  void _initAnimations() {
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _entranceCtrl,
            curve: const Interval(0.00, 0.38, curve: Curves.elasticOut)));
    _logoFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entranceCtrl,
            curve: const Interval(0.00, 0.28, curve: Curves.easeOut)));

    _titleSlide = _sl(0.20, 0.50);  _titleFade = _fa(0.20, 0.50);
    _avatarSlide = _sl(0.40, 0.68); _avatarFade = _fa(0.40, 0.68);
    _fieldSlide  = _sl(0.55, 0.82); _fieldFade  = _fa(0.55, 0.82);
    _btnSlide    = _sl(0.74, 1.00); _btnFade    = _fa(0.74, 1.00);
  }

  Animation<Offset> _sl(double a, double b) =>
      Tween<Offset>(begin: const Offset(0, 0.45), end: Offset.zero).animate(
          CurvedAnimation(parent: _entranceCtrl,
              curve: Interval(a, b, curve: Curves.easeOutQuart)));

  Animation<double> _fa(double a, double b) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _entranceCtrl,
              curve: Interval(a, b, curve: Curves.easeOut)));

  // ---------------------------------------------------------------------------
  // VALIDACIÓN Y GUARDADO
  // ---------------------------------------------------------------------------

  /// Valida el nombre de usuario con las reglas de negocio.
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Por favor ingresa tu nombre';
    }
    if (v.trim().length < 2) {
      return 'Mínimo 2 caracteres';
    }
    if (v.trim().length > 50) {
      return 'Máximo 50 caracteres';
    }
    if (!_kNameRegExp.hasMatch(v.trim())) {
      return 'Solo letras y espacios, por favor';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    if (_isSaving) return;
    _nameFocus.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Captura referencias ANTES de cualquier await — regla BuildContext async
    final profileProvider = context.read<ProfileProvider>();
    final storage         = context.read<StorageService>();

    setState(() => _isSaving = true);
    await HapticFeedback.mediumImpact();

    try {
      await profileProvider.saveProfile(
        name:        _nameCtrl.text,
        loginMethod: widget.loginMethod,
        avatarEmoji: _selectedAvatar,
      );
      await storage.setOnboardingDone();

      if (!mounted) return;

      // Navega al home reemplazando toda la pila de onboarding
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error. Intenta de nuevo.')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Franja de color superior (continuidad visual con WelcomeScreen)
          _HeaderBand(loginMethod: widget.loginMethod),

          // Contenido desplazable
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: safePadding.bottom + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Espacio bajo la franja de color
                  const SizedBox(height: 24),

                  // Logo
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: const _SetupLogo(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Título y método
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: _SetupTitle(method: widget.loginMethod),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Selector de avatar
                  SlideTransition(
                    position: _avatarSlide,
                    child: FadeTransition(
                      opacity: _avatarFade,
                      child: _AvatarPicker(
                        selected: _selectedAvatar,
                        onSelect: (e) =>
                            setState(() => _selectedAvatar = e),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Campo de nombre
                  SlideTransition(
                    position: _fieldSlide,
                    child: FadeTransition(
                      opacity: _fieldFade,
                      child: _NameField(
                        controller: _nameCtrl,
                        focusNode:  _nameFocus,
                        formKey:    _formKey,
                        validator:  _validateName,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botón CTA
                  SlideTransition(
                    position: _btnSlide,
                    child: FadeTransition(
                      opacity: _btnFade,
                      child: _SubmitButton(
                        isSaving: _isSaving,
                        onPressed: _onSubmit,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Texto de privacidad
                  FadeTransition(
                    opacity: _btnFade,
                    child: const _PrivacyNote(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBWIDGETS
// =============================================================================

// --- Franja de color superior ------------------------------------------------

/// Franja verde en la parte superior que cierra visualmente el viaje
/// iniciado en WelcomeScreen (el panel siguió "expandiéndose" hasta cubrir
/// la pantalla completa en la transición slide-up).
class _HeaderBand extends StatelessWidget {
  const _HeaderBand({required this.loginMethod});

  final String loginMethod;

  static const Map<String, ({String label, IconData icon, Color color})>
      _methods = {
    'apple':       (label: 'Apple',          icon: Icons.apple,             color: Color(0xFF1A1A1A)),
    'google':      (label: 'Google',         icon: Icons.g_mobiledata,      color: Color(0xFF4285F4)),
    'email':       (label: 'Correo',         icon: Icons.mail_outline_rounded, color: AppColors.primary),
    'email_login': (label: 'Correo',         icon: Icons.login_rounded,     color: AppColors.primary),
  };

  @override
  Widget build(BuildContext context) {
    final method  = _methods[loginMethod] ?? _methods['email']!;
    final topPad  = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      height: topPad + 56,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD6EEE3),
            Color(0xFFEDF7F2),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
        child: Row(
          children: [
            // Botón de volver
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Volver',
            ),
            const Spacer(),
            // Indicador del método seleccionado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                border: Border.all(
                    color: method.color.withValues(alpha: 0.25), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(method.icon, size: 14, color: method.color),
                  const SizedBox(width: 6),
                  Text(
                    method.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: method.color,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// --- Logo de la pantalla de setup --------------------------------------------

class _SetupLogo extends StatelessWidget {
  const _SetupLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.eco_rounded, size: 46, color: Colors.white),
      ),
    );
  }
}

// --- Título con nombre del método de login -----------------------------------

class _SetupTitle extends StatelessWidget {
  const _SetupTitle({required this.method});

  final String method;

  String get _subtitle {
    switch (method) {
      case 'apple':
        return 'Conectado con Apple ID';
      case 'google':
        return 'Conectado con cuenta de Google';
      case 'email_login':
        return 'Bienvenido de vuelta';
      default:
        return 'Registro con correo electrónico';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        children: [
          Text(
            '¿Cómo te llamamos?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// --- Selector de avatar (emoji) ----------------------------------------------

/// Fila de emojis seleccionables. El seleccionado se marca con
/// un borde verde y escala ligeramente con AnimatedScale.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Elige tu avatar',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 0.5,
                color: AppColors.textTertiary)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _kAvatars.map((emoji) {
            final isSelected = emoji == selected;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(emoji);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width:  isSelected ? 52 : 46,
                height: isSelected ? 52 : 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primarySurface
                      : AppColors.surfaceGray,
                  borderRadius: BorderRadius.circular(
                      isSelected ? 16 : 14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(emoji,
                      style: TextStyle(
                          fontSize: isSelected ? 26 : 22)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// --- Campo de nombre ---------------------------------------------------------

/// Campo de texto con validación reactiva y estilo premium.
class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.focusNode,
    required this.formKey,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final GlobalKey<FormState> formKey;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          textCapitalization: TextCapitalization.words,
          maxLength: 50,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
          // Solo permite letras, tildes, ñ y espacios (capa UI de seguridad)
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
          ],
          decoration: InputDecoration(
            hintText: 'Tu nombre o apodo',
            labelText: 'Nombre de usuario',
            prefixIcon: const Icon(Icons.person_outline_rounded,
                color: AppColors.primary),
            counterStyle: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textTertiary),
            // Borde verde cuando tiene foco — ya configurado en theme.dart
          ),
          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }
}

// --- Botón de envío con estado de carga --------------------------------------

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isSaving,
    required this.onPressed,
  });

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: AppSizes.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          gradient: isSaving
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3D7A5F), Color(0xFF5AAF87)],
                ),
          color: isSaving ? AppColors.primaryLight : null,
          boxShadow: isSaving
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: isSaving ? null : onPressed,
            splashColor: Colors.white.withValues(alpha: 0.15),
            child: Center(
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco_rounded, size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Comenzar mi camino eco',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Nota de privacidad ------------------------------------------------------

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxl),
      child: Text(
        'Al continuar aceptas nuestros términos de uso. '
        'Tus datos se guardan únicamente en este dispositivo.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: AppColors.textTertiary, height: 1.6),
      ),
    );
  }
}
