// =============================================================================
// habit_card.dart — Tarjeta de hábito con animación de completado
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/eco_theme_colors.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../habits/models/habit_model.dart';

class HabitCard extends StatefulWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.date,
    required this.onToggle,
  });

  final Habit habit;
  final DateTime date;
  final VoidCallback onToggle;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _checkAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.94), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.02), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _checkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.3, 1.0, curve: Curves.elasticOut)));

    if (widget.habit.isCompletedOn(widget.date)) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(HabitCard old) {
    super.didUpdateWidget(old);
    final isNowDone = widget.habit.isCompletedOn(widget.date);
    final wasDone   = old.habit.isCompletedOn(old.date);
    if (isNowDone != wasDone) {
      isNowDone ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await HapticFeedback.selectionClick();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isDone   = widget.habit.isCompletedOn(widget.date);
    final category = widget.habit.category;
    final colors   = context.colors;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => ScaleTransition(
        scale: _scaleAnim,
        child: child,
      ),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: AppSizes.sm + 2),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: isDone ? colors.categoryBackground(category) : colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isDone
                  ? category.color.withValues(alpha: 0.35)
                  : colors.border,
              width: isDone ? 1.5 : 1.0,
            ),
            boxShadow: isDone ? null : AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDone
                      ? category.color.withValues(alpha: 0.15)
                      : colors.surfaceGray,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Center(
                  child: Text(widget.habit.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),

              const SizedBox(width: AppSizes.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: isDone
                            ? colors.textSecondary
                            : colors.textPrimary,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _CategoryChip(category: category, isDone: isDone),
                        const SizedBox(width: 6),
                        if (widget.habit.co2SavedKg > 0)
                          _ImpactBadge(
                            label: '${widget.habit.co2SavedKg}kg CO₂',
                            color: AppColors.co2,
                            isDone: isDone,
                          ),
                        if (widget.habit.waterSavedLiters > 0)
                          _ImpactBadge(
                            label: '${widget.habit.waterSavedLiters.toInt()}L',
                            color: AppColors.water,
                            isDone: isDone,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.sm),

              AnimatedBuilder(
                animation: _checkAnim,
                builder: (_, __) => _AnimatedCheckbox(
                  progress: _checkAnim.value,
                  color: category.color,
                  isDone: isDone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Chip de categoría -------------------------------------------------------

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.isDone});

  final HabitCategory category;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: isDone ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: category.color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// --- Badge de impacto --------------------------------------------------------

class _ImpactBadge extends StatelessWidget {
  const _ImpactBadge({
    required this.label,
    required this.color,
    required this.isDone,
  });

  final String label;
  final Color color;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isDone ? color : context.colors.textTertiary,
        ),
      ),
    );
  }
}

// --- Checkbox animado --------------------------------------------------------

class _AnimatedCheckbox extends StatelessWidget {
  const _AnimatedCheckbox({
    required this.progress,
    required this.color,
    required this.isDone,
  });

  final double progress;
  final Color color;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(colors.surfaceGray, color, progress),
        border: Border.all(
          color: Color.lerp(colors.border, color, progress)!,
          width: 2,
        ),
      ),
      child: progress > 0.5
          ? Icon(Icons.check_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: progress))
          : null,
    );
  }
}
