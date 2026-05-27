// =============================================================================
// habit_provider.dart — Gestión de estado de hábitos
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../models/streak_event.dart';
import '../repository/habit_repository.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/services/storage_service.dart';

class HabitProvider extends ChangeNotifier {
  HabitProvider({required StorageService storageService})
      : _repo = HabitRepository(storageService);

  final HabitRepository _repo;

  List<Habit> _habits = [];
  bool _isLoading = false;

  // Último evento de racha pendiente de consumir por la UI.
  StreakEvent? _pendingStreakEvent;
  StreakEvent? get pendingStreakEvent => _pendingStreakEvent;

  void clearStreakEvent() => _pendingStreakEvent = null;

  void _checkStreakEvent(int before, int after, {bool isTimeAdvance = false}) {
    const milestones = {5, 10, 20, 30};
    if (after > before && milestones.contains(after)) {
      _pendingStreakEvent = StreakEvent(StreakEventType.milestone, after);
    } else if (isTimeAdvance && after == 0 && before > 0) {
      _pendingStreakEvent = StreakEvent(StreakEventType.lost, before);
    }
  }

  List<Habit> get habits      => List.unmodifiable(_habits);
  bool        get isLoading   => _isLoading;

  // ---------------------------------------------------------------------------
  // FILTROS
  // ---------------------------------------------------------------------------

  List<Habit> habitsForDate(DateTime date) =>
      _habits.where((h) => h.isScheduledFor(date)).toList();

  List<Habit> get todayHabits => habitsForDate(EcoDateUtils.today());

  int get todayTotal     => todayHabits.length;
  int get todayCompleted =>
      todayHabits.where((h) => h.isCompletedOn(EcoDateUtils.today())).length;

  double get todayProgress =>
      todayTotal == 0 ? 0.0 : todayCompleted / todayTotal;

  // ---------------------------------------------------------------------------
  // IMPACTO TOTAL ACUMULADO
  // ---------------------------------------------------------------------------

  double get totalWaterSaved =>
      _habits.fold(0, (s, h) => s + h.totalWaterSaved);
  double get totalCo2Saved =>
      _habits.fold(0, (s, h) => s + h.totalCo2Saved);
  double get totalEnergySaved =>
      _habits.fold(0, (s, h) => s + h.totalEnergySaved);
  double get totalWasteReduced =>
      _habits.fold(0, (s, h) => s + h.totalWasteReduced);

  // Impacto solo del día de hoy
  double get todayWaterSaved =>
      _completedToday.fold(0, (s, h) => s + h.waterSavedLiters);
  double get todayCo2Saved =>
      _completedToday.fold(0, (s, h) => s + h.co2SavedKg);
  double get todayEnergySaved =>
      _completedToday.fold(0, (s, h) => s + h.energySavedKwh);

  List<Habit> get _completedToday =>
      todayHabits.where((h) => h.isCompletedOn(EcoDateUtils.today())).toList();

  // ---------------------------------------------------------------------------
  // RACHA GLOBAL (días con al menos 1 hábito completado)
  // ---------------------------------------------------------------------------

  int get globalStreak {
    int streak = 0;
    DateTime day = EcoDateUtils.today();
    for (int i = 0; i < 365; i++) {
      final scheduled = habitsForDate(day);
      if (scheduled.isEmpty) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }
      final anyCompleted = scheduled.any((h) => h.isCompletedOn(day));
      if (anyCompleted) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        // Si es hoy y no hay completados todavía, no rompemos aún
        if (i == 0) {
          day = day.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    return streak;
  }

  // ---------------------------------------------------------------------------
  // CARGA
  // ---------------------------------------------------------------------------

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    _habits = _repo.getAll();

    // Si no hay hábitos, cargamos los predeterminados (primer uso)
    if (_habits.isEmpty) {
      _habits = Habit.defaultHabits;
      await _repo.saveAll(_habits);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  Future<void> addHabit(Habit habit) async {
    _habits = [..._habits, habit];
    await _repo.saveAll(_habits);
    notifyListeners();
  }

  Future<void> updateHabit(Habit updated) async {
    _habits = _habits.map((h) => h.id == updated.id ? updated : h).toList();
    await _repo.saveAll(_habits);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    _habits = _habits.where((h) => h.id != id).toList();
    await _repo.saveAll(_habits);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // TOGGLE COMPLETADO
  // ---------------------------------------------------------------------------

  Future<void> toggleCompletion(String habitId, DateTime date) async {
    final streakBefore = globalStreak;
    final key = EcoDateUtils.toKey(date);
    _habits = _habits.map((h) {
      if (h.id != habitId) return h;
      final dates = Set<String>.from(h.completedDates);
      if (dates.contains(key)) {
        dates.remove(key);
      } else {
        dates.add(key);
      }
      return h.copyWith(completedDates: dates);
    }).toList();
    await _repo.saveAll(_habits);
    _checkStreakEvent(streakBefore, globalStreak);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // SIMULACIÓN DE DÍAS (demo/testing)
  // ---------------------------------------------------------------------------

  int get simulatedDayOffset => EcoDateUtils.simulatedDayOffset;

  /// Avanza la fecha simulada un día y recalcula todos los valores derivados.
  void advanceDay() {
    final streakBefore = globalStreak;
    EcoDateUtils.advanceDay();
    _checkStreakEvent(streakBefore, globalStreak, isTimeAdvance: true);
    notifyListeners();
  }

  /// Vuelve a la fecha real del sistema.
  void resetSimulation() {
    EcoDateUtils.resetSimulation();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // RESET (usado en Settings)
  // ---------------------------------------------------------------------------

  Future<void> resetAllData() async {
    EcoDateUtils.resetSimulation();
    _habits = Habit.defaultHabits;
    await _repo.saveAll(_habits);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DATOS DE GRÁFICA SEMANAL
  // ---------------------------------------------------------------------------

  /// Porcentaje de completado (0.0–1.0) por día de la semana actual.
  List<double> get weeklyCompletionRates {
    return EcoDateUtils.currentWeekDays().map((day) {
      final scheduled = habitsForDate(day);
      if (scheduled.isEmpty) return 0.0;
      final done = scheduled.where((h) => h.isCompletedOn(day)).length;
      return done / scheduled.length;
    }).toList();
  }
}
