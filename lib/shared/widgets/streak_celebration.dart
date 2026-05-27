// =============================================================================
// streak_celebration.dart — Overlay animado de rachas (milestone / pérdida)
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../features/habits/models/streak_event.dart';

// ---------------------------------------------------------------------------
// Punto de entrada público
// ---------------------------------------------------------------------------

Future<void> showStreakCelebration(BuildContext context, StreakEvent event) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'streak',
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 480),
    pageBuilder: (ctx, animation, _) =>
        _StreakDialog(event: event, outerAnimation: animation),
    transitionBuilder: (ctx, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// Diálogo principal
// ---------------------------------------------------------------------------

class _StreakDialog extends StatefulWidget {
  const _StreakDialog({
    required this.event,
    required this.outerAnimation,
  });

  final StreakEvent event;
  final Animation<double> outerAnimation;

  @override
  State<_StreakDialog> createState() => _StreakDialogState();
}

class _StreakDialogState extends State<_StreakDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _shakeCtrl;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    // Entrada del card (elasticOut)
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _scaleAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.elasticOut,
    );

    if (widget.event.isMilestone) {
      // Partículas de confeti que caen en bucle
      _particleCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2800),
      )..repeat();
      _shakeCtrl = AnimationController(vsync: this, duration: Duration.zero);
      _shakeAnim = const AlwaysStoppedAnimation(0.0);
    } else {
      // Sacudida horizontal para la pérdida
      _shakeCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..forward();
      _shakeAnim = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 15),
        TweenSequenceItem(tween: Tween(begin: -14.0, end: 14.0), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 14.0, end: -10.0), weight: 20),
        TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 15),
      ]).animate(_shakeCtrl);
      _particleCtrl = AnimationController(vsync: this, duration: Duration.zero);
    }

    // Auto-dismiss
    Future.delayed(
      Duration(milliseconds: widget.event.isMilestone ? 3200 : 2800),
      () { if (mounted) Navigator.of(context, rootNavigator: true).pop(); },
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _particleCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Partículas (solo milestone) ──────────────────────────────
            if (widget.event.isMilestone)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleCtrl,
                  builder: (_, __) => CustomPaint(
                    painter: _ParticlesPainter(_particleCtrl.value),
                    size: const Size(340, 500),
                  ),
                ),
              ),

            // ── Card ─────────────────────────────────────────────────────
            ScaleTransition(
              scale: _scaleAnim,
              child: AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                ),
                child: _buildCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    final isMilestone = widget.event.isMilestone;

    final gradient = isMilestone
        ? const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 288,
        padding: const EdgeInsets.fromLTRB(
            AppSizes.xl, AppSizes.xl, AppSizes.xl, AppSizes.lg),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: isMilestone
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : Colors.black.withValues(alpha: 0.50),
              blurRadius: 36,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Emoji con bounce ────────────────────────────────────────
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Text(
                isMilestone ? '🔥' : '💔',
                style: const TextStyle(fontSize: 64),
              ),
            ),

            const SizedBox(height: AppSizes.md),

            // ── Número / título ─────────────────────────────────────────
            if (isMilestone)
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: widget.event.value),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Text(
                  '¡$v días!',
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1.0,
                    height: 1,
                  ),
                ),
              )
            else
              const Text(
                'Racha perdida',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),

            const SizedBox(height: AppSizes.sm),

            // ── Subtítulo ───────────────────────────────────────────────
            Text(
              isMilestone
                  ? _milestoneSubtitle(widget.event.value)
                  : 'Tenías ${widget.event.value} ${widget.event.value == 1 ? 'día' : 'días'}'
                    ' · ¡Vuelve a empezar!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Pill inferior ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusCircle),
              ),
              child: Text(
                isMilestone ? '¡Sigue así! 🌿' : 'Volver a empezar 💪',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _milestoneSubtitle(int days) {
    if (days >= 30) return '¡Eres un héroe del planeta! 🌍\nTus hábitos hacen historia.';
    if (days >= 20) return '¡Imparable! El medio ambiente\nte lo agradece cada día 🌿';
    if (days >= 10) return '¡Increíble constancia!\nEstás haciendo la diferencia 🌱';
    return '¡Excelente comienzo!\nLa constancia es la clave 🌿';
  }
}

// ---------------------------------------------------------------------------
// CustomPainter de partículas (confeti)
// ---------------------------------------------------------------------------

class _Particle {
  const _Particle(this.x, this.y, this.size, this.speed, this.color, this.angle);
  final double x, y, size, speed, angle;
  final Color color;
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter(this.progress);
  final double progress;

  static final _rnd = math.Random(73);
  static final _colors = [
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.energy,
    AppColors.water,
    Colors.white,
    const Color(0xFFFFD700), // gold
    AppColors.waste,
  ];
  static final List<_Particle> _particles = List.generate(36, (i) => _Particle(
    _rnd.nextDouble(),              // x 0..1
    _rnd.nextDouble(),              // y 0..1 (initial offset)
    _rnd.nextDouble() * 5 + 3,     // radius
    _rnd.nextDouble() * 0.35 + 0.15, // fall speed
    _colors[i % _colors.length],
    _rnd.nextDouble() * math.pi,   // rotation angle (unused, kept for parity)
  ));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in _particles) {
      final y = ((p.y + progress * p.speed) % 1.0) * size.height;
      final x = p.x * size.width;
      final opacity = (1.0 - (y / size.height) * 0.6).clamp(0.3, 1.0);
      paint.color = p.color.withValues(alpha: opacity);
      // Alternate between circles and small squares for variety
      if (_particles.indexOf(p).isEven) {
        canvas.drawCircle(Offset(x, y), p.size, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(x, y), width: p.size * 1.6, height: p.size),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.progress != progress;
}
