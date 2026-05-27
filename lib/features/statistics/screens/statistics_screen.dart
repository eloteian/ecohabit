// =============================================================================
// statistics_screen.dart — Impacto ambiental, pie chart e historial calendario
// =============================================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/eco_theme_colors.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_utils.dart';
import '../../habits/models/habit_model.dart';
import '../../habits/providers/habit_provider.dart';
import '../providers/statistics_provider.dart';

// =============================================================================
// HELPERS DE COMPARTIR
// =============================================================================

void _shareImpact(
    BuildContext context, HabitProvider habits, StatisticsProvider stats) {
  final streak = habits.globalStreak;
  final completions = stats.totalCompletions;
  final water = stats.totalWater.toInt();
  final co2 = stats.totalCo2.toStringAsFixed(1);
  final energy = stats.totalEnergy.toStringAsFixed(1);

  final text = '''
🌿 Mi impacto en EcoHabit 🌿

🔥 $streak días de racha
✅ $completions completaciones

💧 ${water}L de agua ahorrados
🌿 ${co2}kg de CO₂ reducidos
⚡ ${energy}kWh de energía ahorrados

¡Pequeñas acciones, gran impacto! 🌍
Descarga EcoHabit y únete al reto.
''';

  SharePlus.instance.share(ShareParams(text: text.trim()));
}

// =============================================================================
// PANTALLA PRINCIPAL
// =============================================================================

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Consumer2<HabitProvider, StatisticsProvider>(
        builder: (context, habits, stats, _) {
          final habitList = habits.habits.toList();
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                snap: true,
                backgroundColor: context.colors.background,
                title: Text('Mi Impacto',
                    style: Theme.of(context).textTheme.titleLarge),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: AppColors.primary),
                    tooltip: 'Compartir impacto',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _shareImpact(context, habits, stats);
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding, 8,
                    AppSizes.screenPadding, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    _ImpactHeader(stats: stats),
                    const SizedBox(height: AppSizes.lg),

                    _EquivalencesSection(stats: stats),
                    const SizedBox(height: AppSizes.lg),

                    _WeeklyChartSection(habits: habits),
                    const SizedBox(height: AppSizes.lg),

                    _TopHabitsPieSection(habits: habitList),
                    const SizedBox(height: AppSizes.lg),

                    _CategoryBreakdown(stats: stats),
                    const SizedBox(height: AppSizes.lg),

                    _ConsistencyCard(habit: stats.mostConsistentHabit),
                    const SizedBox(height: AppSizes.lg),

                    _HistorySection(
                      habits: habitList,
                      onToggle: (id, date) =>
                          context.read<HabitProvider>().toggleCompletion(id, date),
                    ),

                    const SizedBox(height: AppSizes.xl),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// SECCIÓN: ENCABEZADO DE IMPACTO
// =============================================================================

class _ImpactHeader extends StatelessWidget {
  const _ImpactHeader({required this.stats});
  final StatisticsProvider stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.impactGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impacto total acumulado',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.80),
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            '${stats.totalCompletions} completaciones',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              _StatPill(icon: '💧', value: '${stats.totalWater.toInt()}L',  label: 'agua'),
              const SizedBox(width: AppSizes.sm),
              _StatPill(icon: '🌿', value: '${stats.totalCo2.toStringAsFixed(1)}kg', label: 'CO₂'),
              const SizedBox(width: AppSizes.sm),
              _StatPill(icon: '⚡', value: '${stats.totalEnergy.toStringAsFixed(1)}kWh', label: 'energía'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.value, required this.label});
  final String icon, value, label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SECCIÓN: EQUIVALENCIAS
// =============================================================================

class _EquivalencesSection extends StatelessWidget {
  const _EquivalencesSection({required this.stats});
  final StatisticsProvider stats;

  @override
  Widget build(BuildContext context) {
    if (stats.totalCompletions == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Equivale a…', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            if (stats.waterBottles > 0)
              Expanded(child: _EquivCard(
                  icon: '🍶', value: '${stats.waterBottles}',
                  label: 'botellas\nde 500 ml', color: AppColors.water)),
            if (stats.waterBottles > 0 && stats.co2CarKm > 0)
              const SizedBox(width: AppSizes.sm),
            if (stats.co2CarKm > 0)
              Expanded(child: _EquivCard(
                  icon: '🚗', value: '${stats.co2CarKm} km',
                  label: 'sin emitir\nen coche', color: AppColors.co2)),
            if (stats.co2CarKm > 0 && stats.energyTvHours > 0)
              const SizedBox(width: AppSizes.sm),
            if (stats.energyTvHours > 0)
              Expanded(child: _EquivCard(
                  icon: '📺', value: '${stats.energyTvHours}h',
                  label: 'de televisión\nahorradas', color: AppColors.energy)),
          ],
        ),
      ],
    );
  }
}

class _EquivCard extends StatelessWidget {
  const _EquivCard({
    required this.icon, required this.value,
    required this.label, required this.color,
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
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall, maxLines: 2),
        ],
      ),
    );
  }
}

// =============================================================================
// SECCIÓN: BARRAS SEMANALES
// =============================================================================

class _WeeklyChartSection extends StatelessWidget {
  const _WeeklyChartSection({required this.habits});
  final HabitProvider habits;

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final rates    = habits.weeklyCompletionRates;
    final weekDays = EcoDateUtils.currentWeekDays();
    final todayKey = EcoDateUtils.toKey(EcoDateUtils.today());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Esta semana', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(
              AppSizes.sm, AppSizes.md, AppSizes.sm, AppSizes.xs),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: colors.border),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1.0,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= weekDays.length) {
                        return const SizedBox.shrink();
                      }
                      final isToday =
                          EcoDateUtils.toKey(weekDays[i]) == todayKey;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          EcoDateUtils.shortWeekday(weekDays[i].weekday),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? AppColors.primary
                                : colors.textTertiary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 0.5,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colors.border,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (i) {
                final rate    = i < rates.length ? rates[i] : 0.0;
                final isToday =
                    i < weekDays.length &&
                    EcoDateUtils.toKey(weekDays[i]) == todayKey;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: rate.clamp(0.0, 1.0),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                      gradient: LinearGradient(
                        colors: isToday
                            ? [AppColors.primaryLight, AppColors.primary]
                            : [
                                AppColors.primary.withValues(alpha: 0.35),
                                AppColors.primary.withValues(alpha: 0.60),
                              ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ],
                );
              }),
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SECCIÓN: PIE CHART
// =============================================================================

class _TopHabitsPieSection extends StatefulWidget {
  const _TopHabitsPieSection({required this.habits});
  final List<Habit> habits;

  @override
  State<_TopHabitsPieSection> createState() => _TopHabitsPieSectionState();
}

class _TopHabitsPieSectionState extends State<_TopHabitsPieSection> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sorted = [...widget.habits]
      ..sort((a, b) => b.totalCompletions.compareTo(a.totalCompletions));
    final top = sorted.where((h) => h.totalCompletions > 0).take(5).toList();

    if (top.isEmpty) return const SizedBox.shrink();

    final total = top.fold(0, (s, h) => s + h.totalCompletions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hábitos más consistentes',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: top.asMap().entries.map((e) {
                            final i         = e.key;
                            final h         = e.value;
                            final isTouched = i == _touchedIndex;
                            final pct       =
                                total > 0 ? h.totalCompletions / total : 0.0;
                            return PieChartSectionData(
                              value:  h.totalCompletions.toDouble(),
                              color:  h.category.color,
                              radius: isTouched ? 88 : 72,
                              title: '${(pct * 100).toStringAsFixed(0)}%',
                              titleStyle: TextStyle(
                                fontSize: isTouched ? 13 : 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace:    3,
                          centerSpaceRadius: 36,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, resp) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    resp?.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex =
                                    resp!.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                        ),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      ),
                    ),

                    const SizedBox(width: AppSizes.md),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: top.asMap().entries.map((e) {
                        final i       = e.key;
                        final h       = e.value;
                        final touched = i == _touchedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Row(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: h.category.color,
                                ),
                              ),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 110),
                                child: Text(
                                  '${h.emoji} ${h.name}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: touched
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    color: touched
                                        ? colors.textPrimary
                                        : colors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              if (_touchedIndex >= 0 && _touchedIndex < top.length) ...[
                const Divider(height: 16),
                Row(
                  children: [
                    Text(top[_touchedIndex].emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(top[_touchedIndex].name,
                              style: Theme.of(context).textTheme.titleSmall),
                          Text(
                            '${top[_touchedIndex].totalCompletions} completaciones'
                            ' · racha ${top[_touchedIndex].currentStreak} días',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SECCIÓN: DISTRIBUCIÓN POR CATEGORÍA
// =============================================================================

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.stats});
  final StatisticsProvider stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final byCategory = stats.completionsByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();
    final total = byCategory.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Por categoría', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: sorted.map((entry) {
              final cat   = entry.key;
              final count = entry.value;
              final pct   = count / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('${cat.emoji} ${cat.label}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('$count veces',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusCircle),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 8,
                          backgroundColor: colors.surfaceGray,
                          valueColor: AlwaysStoppedAnimation(cat.color),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SECCIÓN: HÁBITO MÁS CONSISTENTE
// =============================================================================

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard({required this.habit});
  final Habit? habit;

  @override
  Widget build(BuildContext context) {
    if (habit == null) return const SizedBox.shrink();
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Más consistente',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: colors.categoryBackground(habit!.category),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border:
                Border.all(color: habit!.category.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: habit!.category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Center(
                    child: Text(habit!.emoji,
                        style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit!.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: colors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '${habit!.totalCompletions} completaciones · '
                      '${habit!.currentStreak} días de racha',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Text('🏆', style: TextStyle(fontSize: 26)),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SECCIÓN: HISTORIAL
// =============================================================================

enum _CalMode { week, day }

class _HistorySection extends StatefulWidget {
  const _HistorySection({
    required this.habits,
    required this.onToggle,
  });

  final List<Habit> habits;
  final void Function(String habitId, DateTime date) onToggle;

  @override
  State<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<_HistorySection> {
  _CalMode _mode = _CalMode.week;
  late DateTime _ref;

  @override
  void initState() {
    super.initState();
    _ref = EcoDateUtils.today();
  }

  DateTime get _weekStart => EcoDateUtils.startOfWeek(_ref);
  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Historial',
                style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<_CalMode>(
              segments: const [
                ButtonSegment(
                    value: _CalMode.week,
                    label: Text('Semana'),
                    icon: Icon(Icons.view_week_outlined, size: 15)),
                ButtonSegment(
                    value: _CalMode.day,
                    label: Text('Día'),
                    icon: Icon(Icons.today_outlined, size: 15)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) =>
                  setState(() => _mode = s.first),
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 12)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.sm),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          child: _mode == _CalMode.week
              ? _WeekCalendar(
                  key: ValueKey('week_$_weekStart'),
                  habits:   widget.habits,
                  weekDays: _weekDays,
                  onPrev: () => setState(() =>
                      _ref = _ref.subtract(const Duration(days: 7))),
                  onNext: () => setState(() =>
                      _ref = _ref.add(const Duration(days: 7))),
                  onToggle: widget.onToggle,
                )
              : _DayHistory(
                  key: ValueKey('day_${EcoDateUtils.toKey(_ref)}'),
                  habits:  widget.habits,
                  date:    _ref,
                  onPrev: () => setState(() =>
                      _ref = _ref.subtract(const Duration(days: 1))),
                  onNext: () => setState(() =>
                      _ref = _ref.add(const Duration(days: 1))),
                  onToggle: widget.onToggle,
                ),
        ),
      ],
    );
  }
}

// =============================================================================
// VISTA SEMANAL
// =============================================================================

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({
    super.key,
    required this.habits,
    required this.weekDays,
    required this.onPrev,
    required this.onNext,
    required this.onToggle,
  });

  final List<Habit>  habits;
  final List<DateTime> weekDays;
  final VoidCallback onPrev, onNext;
  final void Function(String, DateTime) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final todayKey  = EcoDateUtils.toKey(EcoDateUtils.today());
    final firstDay  = weekDays.first;
    final lastDay   = weekDays.last;
    final sameMonth = firstDay.month == lastDay.month;
    final rangeLabel = sameMonth
        ? '${firstDay.day}–${lastDay.day} ${EcoDateUtils.monthName(firstDay.month).substring(0, 3)}'
        : '${firstDay.day} ${EcoDateUtils.monthName(firstDay.month).substring(0, 3)} – '
          '${lastDay.day} ${EcoDateUtils.monthName(lastDay.month).substring(0, 3)}';

    final relevant = habits
        .where((h) => weekDays.any((d) => h.isScheduledFor(d)))
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _CalNavRow(label: rangeLabel, onPrev: onPrev, onNext: onNext),

          const SizedBox(height: AppSizes.sm),

          Row(
            children: [
              const SizedBox(width: 36),
              ...weekDays.map((d) {
                final isToday = EcoDateUtils.toKey(d) == todayKey;
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        EcoDateUtils.shortWeekday(d.weekday),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isToday
                              ? AppColors.primary
                              : colors.textTertiary,
                        ),
                      ),
                      Text(
                        '${d.day}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: isToday
                              ? AppColors.primary
                              : colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),

          if (relevant.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Text(
                'Sin hábitos programados esta semana',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textTertiary),
              ),
            )
          else
            ...relevant.map((h) => _WeekHabitRow(
                  habit:    h,
                  weekDays: weekDays,
                  todayKey: todayKey,
                  onToggle: onToggle,
                )),

          const SizedBox(height: AppSizes.sm),

          Row(
            children: [
              const _LegendDot(color: AppColors.primary, label: 'Completado'),
              const SizedBox(width: AppSizes.md),
              _LegendDot(color: colors.border, label: 'Pendiente', outlined: true),
              const SizedBox(width: AppSizes.md),
              Text('–  No prog.',
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekHabitRow extends StatelessWidget {
  const _WeekHabitRow({
    required this.habit,
    required this.weekDays,
    required this.todayKey,
    required this.onToggle,
  });
  final Habit habit;
  final List<DateTime> weekDays;
  final String todayKey;
  final void Function(String, DateTime) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(habit.emoji,
                style: const TextStyle(fontSize: 16)),
          ),
          ...weekDays.map((d) {
            final scheduled = habit.isScheduledFor(d);
            final completed = habit.isCompletedOn(d);
            final isFuture  =
                d.isAfter(EcoDateUtils.today());
            final dayKey    = EcoDateUtils.toKey(d);
            final isToday   = dayKey == todayKey;

            if (!scheduled) {
              return Expanded(
                child: Center(
                  child: Text('–',
                      style: TextStyle(
                          color: colors.textTertiary, fontSize: 11)),
                ),
              );
            }

            return Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: isFuture ? null : () => onToggle(habit.id, d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed
                          ? habit.category.color
                          : Colors.transparent,
                      border: Border.all(
                        color: completed
                            ? habit.category.color
                            : isToday
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : isFuture
                                    ? colors.border.withValues(alpha: 0.4)
                                    : colors.border,
                        width: isToday && !completed ? 2 : 1.5,
                      ),
                    ),
                    child: completed
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================================
// VISTA DIARIA
// =============================================================================

class _DayHistory extends StatelessWidget {
  const _DayHistory({
    super.key,
    required this.habits,
    required this.date,
    required this.onPrev,
    required this.onNext,
    required this.onToggle,
  });

  final List<Habit> habits;
  final DateTime date;
  final VoidCallback onPrev, onNext;
  final void Function(String, DateTime) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors      = context.colors;
    final today       = EcoDateUtils.today();
    final isFuture    = date.isAfter(today);
    final isToday     = EcoDateUtils.toKey(date) == EcoDateUtils.toKey(today);
    final scheduled   = habits.where((h) => h.isScheduledFor(date)).toList();
    final unscheduled = habits.where((h) => !h.isScheduledFor(date)).toList();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.4)
              : colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CalNavRow(
            label: EcoDateUtils.friendlyDate(date),
            onPrev: onPrev,
            onNext: onNext,
          ),

          const Divider(height: 16),

          if (scheduled.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Text(
                'Sin hábitos programados para este día',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.textTertiary),
              ),
            )
          else
            ...scheduled.map((h) {
              final done = h.isCompletedOn(date);
              return GestureDetector(
                onTap: isFuture ? null : () => onToggle(h.id, date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(bottom: AppSizes.xs),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: done
                        ? colors.categoryBackground(h.category)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(
                      color: done
                          ? h.category.color.withValues(alpha: 0.3)
                          : colors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(h.emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          h.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: done
                                ? colors.textSecondary
                                : colors.textPrimary,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: colors.textTertiary,
                          ),
                        ),
                      ),
                      if (isFuture)
                        Text('Próximo',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: colors.textTertiary))
                      else if (done)
                        Icon(Icons.check_circle_rounded,
                            size: 18, color: h.category.color)
                      else
                        Icon(Icons.radio_button_unchecked_rounded,
                            size: 18, color: colors.border),
                    ],
                  ),
                ),
              );
            }),

          if (unscheduled.isNotEmpty) ...[
            if (scheduled.isNotEmpty) ...[
              const SizedBox(height: AppSizes.xs),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.xs),
            ],
            ...unscheduled.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(h.emoji,
                          style: TextStyle(
                              fontSize: 16,
                              color: colors.textTertiary
                                  .withValues(alpha: 0.5))),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(h.name,
                            style: TextStyle(
                                fontSize: 12,
                                color: colors.textTertiary)),
                      ),
                      Text('No programado',
                          style: TextStyle(
                              fontSize: 10,
                              color: colors.textTertiary)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// HELPERS COMPARTIDOS
// =============================================================================

class _CalNavRow extends StatelessWidget {
  const _CalNavRow({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });
  final String label;
  final VoidCallback onPrev, onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: onPrev,
          color: colors.textSecondary,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: onNext,
          color: colors.textSecondary,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.outlined = false,
  });
  final Color color;
  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: outlined ? Colors.transparent : color,
            border: outlined
                ? Border.all(color: colors.textTertiary)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
