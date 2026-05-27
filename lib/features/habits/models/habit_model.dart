// =============================================================================
// habit_model.dart — Modelo de dominio de un Hábito Sostenible
// =============================================================================
// Clase inmutable con serialización JSON y helpers de cálculo de impacto.
// Toda mutación devuelve una nueva instancia via copyWith().
// =============================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';

// =============================================================================
// ENUMERACIÓN DE CATEGORÍAS
// =============================================================================

enum HabitCategory {
  water,
  energy,
  food,
  transport,
  waste;

  String get label {
    switch (this) {
      case water:     return 'Agua';
      case energy:    return 'Energía';
      case food:      return 'Alimentación';
      case transport: return 'Transporte';
      case waste:     return 'Residuos';
    }
  }

  String get emoji {
    switch (this) {
      case water:     return '💧';
      case energy:    return '⚡';
      case food:      return '🥗';
      case transport: return '🚴';
      case waste:     return '♻️';
    }
  }

  Color get color {
    switch (this) {
      case water:     return AppColors.water;
      case energy:    return AppColors.energy;
      case food:      return AppColors.co2;
      case transport: return AppColors.primaryLight;
      case waste:     return AppColors.waste;
    }
  }

  Color get surfaceColor {
    switch (this) {
      case water:     return const Color(0xFFDCF0FA);
      case energy:    return const Color(0xFFFFEEDD);
      case food:      return AppColors.primarySurface;
      case transport: return const Color(0xFFDFF2E9);
      case waste:     return const Color(0xFFEDE0F7);
    }
  }

  String toJson() => name;
  static HabitCategory fromJson(String v) =>
      HabitCategory.values.firstWhere((e) => e.name == v,
          orElse: () => HabitCategory.water);
}

// =============================================================================
// MODELO PRINCIPAL
// =============================================================================

/// Representa un hábito sostenible con su programación semanal e impacto.
///
/// - [weekDays]: lista de 7 bool (índice 0 = Lunes, 6 = Domingo).
/// - [completedDates]: conjunto de claves 'yyyy-MM-dd' de días completados.
/// - Los campos de impacto representan el ahorro POR completación.
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.weekDays,
    required this.completedDates,
    required this.createdAt,
    this.description = '',
    this.waterSavedLiters   = 0.0,
    this.co2SavedKg         = 0.0,
    this.energySavedKwh     = 0.0,
    this.wasteReducedGrams  = 0.0,
  });

  final String         id;
  final String         name;
  final String         emoji;
  final String         description;
  final HabitCategory  category;
  final List<bool>     weekDays;        // [L,M,X,J,V,S,D]
  final Set<String>    completedDates;  // 'yyyy-MM-dd'
  final DateTime       createdAt;

  // Impacto ambiental por completación
  final double waterSavedLiters;
  final double co2SavedKg;
  final double energySavedKwh;
  final double wasteReducedGrams;

  // ---------------------------------------------------------------------------
  // HELPERS DE PROGRAMACIÓN Y COMPLETADO
  // ---------------------------------------------------------------------------

  bool isScheduledFor(DateTime date) =>
      weekDays[EcoDateUtils.weekdayIndex(date)];

  bool isCompletedOn(DateTime date) =>
      completedDates.contains(EcoDateUtils.toKey(date));

  // ---------------------------------------------------------------------------
  // ESTADÍSTICAS ACUMULADAS
  // ---------------------------------------------------------------------------

  int    get totalCompletions     => completedDates.length;
  double get totalWaterSaved      => totalCompletions * waterSavedLiters;
  double get totalCo2Saved        => totalCompletions * co2SavedKg;
  double get totalEnergySaved     => totalCompletions * energySavedKwh;
  double get totalWasteReduced    => totalCompletions * wasteReducedGrams;

  // Días programados en la semana actual con completados
  int completedThisWeek() {
    return EcoDateUtils.currentWeekDays()
        .where((d) => isScheduledFor(d) && isCompletedOn(d))
        .length;
  }

  int scheduledThisWeek() {
    return EcoDateUtils.currentWeekDays()
        .where((d) => isScheduledFor(d))
        .length;
  }

  // ---------------------------------------------------------------------------
  // RACHA ACTUAL (streak)
  // ---------------------------------------------------------------------------

  /// Días consecutivos hacia atrás con todas las completaciones programadas.
  int get currentStreak {
    int streak = 0;
    DateTime day = EcoDateUtils.today();

    // Si hoy está programado pero no completado, no rompe la racha aún
    if (isScheduledFor(day) && !isCompletedOn(day)) {
      day = day.subtract(const Duration(days: 1));
    }

    while (true) {
      if (isScheduledFor(day)) {
        if (isCompletedOn(day)) {
          streak++;
        } else {
          break;
        }
      }
      day = day.subtract(const Duration(days: 1));
      // Límite: no buscar más de 365 días
      if (day.isBefore(createdAt.subtract(const Duration(days: 1)))) break;
    }
    return streak;
  }

  // ---------------------------------------------------------------------------
  // COPYWIDTH
  // ---------------------------------------------------------------------------

  Habit copyWith({
    String? name,
    String? emoji,
    String? description,
    HabitCategory? category,
    List<bool>? weekDays,
    Set<String>? completedDates,
    double? waterSavedLiters,
    double? co2SavedKg,
    double? energySavedKwh,
    double? wasteReducedGrams,
  }) {
    return Habit(
      id:                 id,
      name:               name               ?? this.name,
      emoji:              emoji              ?? this.emoji,
      description:        description        ?? this.description,
      category:           category           ?? this.category,
      weekDays:           weekDays           ?? this.weekDays,
      completedDates:     completedDates     ?? this.completedDates,
      createdAt:          createdAt,
      waterSavedLiters:   waterSavedLiters   ?? this.waterSavedLiters,
      co2SavedKg:         co2SavedKg         ?? this.co2SavedKg,
      energySavedKwh:     energySavedKwh     ?? this.energySavedKwh,
      wasteReducedGrams:  wasteReducedGrams  ?? this.wasteReducedGrams,
    );
  }

  // ---------------------------------------------------------------------------
  // SERIALIZACIÓN
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
    'id':                id,
    'name':              name,
    'emoji':             emoji,
    'description':       description,
    'category':          category.toJson(),
    'weekDays':          weekDays,
    'completedDates':    completedDates.toList(),
    'createdAt':         createdAt.toIso8601String(),
    'waterSavedLiters':  waterSavedLiters,
    'co2SavedKg':        co2SavedKg,
    'energySavedKwh':    energySavedKwh,
    'wasteReducedGrams': wasteReducedGrams,
  };

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
    id:               j['id']              as String,
    name:             j['name']            as String,
    emoji:            j['emoji']           as String? ?? '🌱',
    description:      j['description']     as String? ?? '',
    category:         HabitCategory.fromJson(j['category'] as String? ?? 'water'),
    weekDays:         (j['weekDays']       as List<dynamic>).cast<bool>(),
    completedDates:   Set<String>.from(
                        (j['completedDates'] as List<dynamic>).cast<String>()),
    createdAt:        DateTime.parse(j['createdAt'] as String),
    waterSavedLiters:  (j['waterSavedLiters']  as num?)?.toDouble() ?? 0.0,
    co2SavedKg:        (j['co2SavedKg']         as num?)?.toDouble() ?? 0.0,
    energySavedKwh:    (j['energySavedKwh']     as num?)?.toDouble() ?? 0.0,
    wasteReducedGrams: (j['wasteReducedGrams']  as num?)?.toDouble() ?? 0.0,
  );

  // ---------------------------------------------------------------------------
  // FÁBRICA DE HÁBITOS PREDETERMINADOS (seed data)
  // ---------------------------------------------------------------------------

  static List<Habit> get defaultHabits {
    final now = DateTime.now();
    final allDays = List.filled(7, true);
    final weekdays = [true, true, true, true, true, false, false];

    return [
      Habit(
        id: '${now.microsecondsSinceEpoch}_1',
        name: 'Ducha de 5 minutos',
        emoji: '🚿',
        description: 'Limita tu ducha a 5 minutos para ahorrar agua',
        category: HabitCategory.water,
        weekDays: allDays,
        completedDates: const {},
        createdAt: now,
        waterSavedLiters: 55,
        co2SavedKg: 0.05,
      ),
      Habit(
        id: '${now.microsecondsSinceEpoch}_2',
        name: 'Almuerzo vegetariano',
        emoji: '🥗',
        description: 'Un almuerzo sin carne reduce tu huella de carbono',
        category: HabitCategory.food,
        weekDays: weekdays,
        completedDates: const {},
        createdAt: now,
        co2SavedKg: 1.5,
      ),
      Habit(
        id: '${now.microsecondsSinceEpoch}_3',
        name: 'Ir en bicicleta o caminar',
        emoji: '🚴',
        description: 'Sustituye el coche por bici o caminata',
        category: HabitCategory.transport,
        weekDays: weekdays,
        completedDates: const {},
        createdAt: now,
        co2SavedKg: 1.2,
      ),
      Habit(
        id: '${now.microsecondsSinceEpoch}_4',
        name: 'Separar el reciclaje',
        emoji: '♻️',
        description: 'Clasifica papel, plástico, vidrio y orgánico',
        category: HabitCategory.waste,
        weekDays: allDays,
        completedDates: const {},
        createdAt: now,
        co2SavedKg: 0.5,
        wasteReducedGrams: 400,
      ),
      Habit(
        id: '${now.microsecondsSinceEpoch}_5',
        name: 'Apagar luces al salir',
        emoji: '💡',
        description: 'Revisa que no quede ninguna luz encendida',
        category: HabitCategory.energy,
        weekDays: allDays,
        completedDates: const {},
        createdAt: now,
        co2SavedKg: 0.3,
        energySavedKwh: 1.5,
      ),
    ];
  }
}
