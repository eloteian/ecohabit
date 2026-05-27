// =============================================================================
// home_screen.dart — Dashboard principal de EcoHabit
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/eco_theme_colors.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../features/habits/models/habit_model.dart';
import '../../../features/habits/providers/habit_provider.dart';
import '../../../features/habits/screens/habit_form_screen.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../shared/widgets/streak_celebration.dart';
import '../widgets/habit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _StreakWatcher(
        child: Scaffold(
      backgroundColor: context.colors.background,
      body: Consumer2<HabitProvider, ProfileProvider>(
        builder: (context, habits, profile, _) {
          final today = EcoDateUtils.today();
          final todayList = habits.todayHabits;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ─────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                snap: true,
                backgroundColor: context.colors.background,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${profile.name.isEmpty ? 'Eco Usuario' : profile.name} ${profile.avatarEmoji}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      EcoDateUtils.friendlyDate(today),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.primary, size: 28),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.habitForm),
                    tooltip: 'Nuevo hábito',
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              // ── Cuerpo ─────────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding, 8, AppSizes.screenPadding, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _DaySimulatorBanner(
                      dayOffset: habits.simulatedDayOffset,
                      onAdvance: () {
                        HapticFeedback.selectionClick();
                        habits.advanceDay();
                      },
                      onReset: () {
                        HapticFeedback.selectionClick();
                        habits.resetSimulation();
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    _ProgressCard(
                      completed: habits.todayCompleted,
                      total: habits.todayTotal,
                      progress: habits.todayProgress,
                      streak: habits.globalStreak,
                    ),
                    const SizedBox(height: AppSizes.md),
                    _TodayImpactRow(
                      water: habits.todayWaterSaved,
                      co2: habits.todayCo2Saved,
                      energy: habits.todayEnergySaved,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hábitos de hoy',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('${todayList.length} programados',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    if (todayList.isEmpty)
                      _EmptyHabitsCard(
                          onAdd: () =>
                              Navigator.pushNamed(context, AppRoutes.habitForm))
                    else
                      ...todayList.map((habit) => _SwipableHabitCard(
                            habit: habit,
                            date: today,
                            onToggle: () => context
                                .read<HabitProvider>()
                                .toggleCompletion(habit.id, today),
                            onDelete: () => context
                                .read<HabitProvider>()
                                .deleteHabit(habit.id),
                          )),
                    if (todayList.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Todos mis hábitos',
                              style: Theme.of(context).textTheme.titleMedium),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.habitForm),
                            child: const Text('+ Añadir'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      ...habits.habits
                          .where((h) => !h.isScheduledFor(today))
                          .map((habit) => _InactiveHabitRow(
                                habit: habit,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HabitFormScreen(habitToEdit: habit),
                                  ),
                                ),
                              )),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}

// =============================================================================
// STREAK WATCHER
// =============================================================================

class _StreakWatcher extends StatefulWidget {
  const _StreakWatcher({required this.child});
  final Widget child;

  @override
  State<_StreakWatcher> createState() => _StreakWatcherState();
}

class _StreakWatcherState extends State<_StreakWatcher> {
  HabitProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = context.read<HabitProvider>();
    if (_provider != newProvider) {
      _provider?.removeListener(_onChanged);
      _provider = newProvider;
      _provider!.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final event = _provider?.pendingStreakEvent;
    if (event != null && mounted) {
      _provider!.clearStreakEvent();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showStreakCelebration(context, event);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// =============================================================================
// SUBWIDGETS
// =============================================================================

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
    required this.streak,
  });

  final int completed, total, streak;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => CircularProgressIndicator(
                    value: v,
                    strokeWidth: 2.5,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0
                      ? 'Sin hábitos hoy'
                      : '$completed de $total completados',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completed == total && total > 0
                      ? '¡Día perfecto! 🎉'
                      : 'Sigue así, vas bien',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                ),
                if (streak > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusCircle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '$streak día${streak == 1 ? '' : 's'} de racha',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayImpactRow extends StatelessWidget {
  const _TodayImpactRow({
    required this.water,
    required this.co2,
    required this.energy,
  });

  final double water, co2, energy;

  @override
  Widget build(BuildContext context) {
    if (water == 0 && co2 == 0 && energy == 0) return const SizedBox.shrink();

    return Row(
      children: [
        if (water > 0)
          Expanded(
              child: _ImpactTile(
                  icon: '💧',
                  value: '${water.toInt()}L',
                  label: 'Agua hoy',
                  color: AppColors.water)),
        if (water > 0 && (co2 > 0 || energy > 0))
          const SizedBox(width: AppSizes.sm),
        if (co2 > 0)
          Expanded(
              child: _ImpactTile(
                  icon: '🌿',
                  value: '${co2.toStringAsFixed(1)}kg',
                  label: 'CO₂ hoy',
                  color: AppColors.co2)),
        if (co2 > 0 && energy > 0) const SizedBox(width: AppSizes.sm),
        if (energy > 0)
          Expanded(
              child: _ImpactTile(
                  icon: '⚡',
                  value: '${energy.toStringAsFixed(1)}kWh',
                  label: 'Energía hoy',
                  color: AppColors.energy)),
      ],
    );
  }
}

class _ImpactTile extends StatelessWidget {
  const _ImpactTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final String icon, value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _EmptyHabitsCard extends StatelessWidget {
  const _EmptyHabitsCard({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border:
            Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('¡No hay hábitos para hoy!',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text('Añade tu primer hábito sostenible',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear hábito'),
          ),
        ],
      ),
    );
  }
}

class _InactiveHabitRow extends StatelessWidget {
  const _InactiveHabitRow({required this.habit, required this.onTap});

  final Habit habit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm + 2),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Text(habit.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(habit.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.textSecondary)),
            ),
            Text('No hoy', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SWIPE-TO-DELETE WRAPPER
// =============================================================================

class _SwipableHabitCard extends StatelessWidget {
  const _SwipableHabitCard({
    required this.habit,
    required this.date,
    required this.onToggle,
    required this.onDelete,
  });

  final Habit habit;
  final DateTime date;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content:
            Text('¿Eliminar "${habit.name}"?\nSe perderá todo su historial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm + 2),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text('Eliminar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      child: HabitCard(
        habit: habit,
        date: date,
        onToggle: onToggle,
      ),
    );
  }
}

// =============================================================================
// BANNER DE SIMULACIÓN DE DÍAS
// =============================================================================

class _DaySimulatorBanner extends StatelessWidget {
  const _DaySimulatorBanner({
    required this.dayOffset,
    required this.onAdvance,
    required this.onReset,
  });

  final int dayOffset;
  final VoidCallback onAdvance;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSimulating = dayOffset > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 10),
      decoration: BoxDecoration(
        color: isSimulating
            ? AppColors.energy.withValues(alpha: 0.10)
            : colors.surfaceGray,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: isSimulating ? AppColors.energy : colors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.science_outlined,
            size: 16,
            color: isSimulating ? AppColors.energy : colors.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isSimulating
                  ? 'Simulando +$dayOffset ${dayOffset == 1 ? 'día' : 'días'}'
                  : 'Modo demo: simula el paso del tiempo',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        isSimulating ? AppColors.energy : colors.textTertiary,
                    fontWeight:
                        isSimulating ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
          if (isSimulating)
            TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
                foregroundColor: colors.textSecondary,
              ),
              child: const Text('Restablecer', style: TextStyle(fontSize: 11)),
            ),
          FilledButton.tonal(
            onPressed: onAdvance,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 28),
              backgroundColor: isSimulating
                  ? AppColors.energy.withValues(alpha: 0.15)
                  : colors.border,
              foregroundColor:
                  isSimulating ? AppColors.energy : colors.textSecondary,
              textStyle:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            child: const Text('+ 1 día'),
          ),
        ],
      ),
    );
  }
}
