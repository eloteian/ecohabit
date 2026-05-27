// =============================================================================
// statistics_provider.dart — Métricas de impacto ambiental
// =============================================================================

import 'package:flutter/foundation.dart';
import '../../habits/models/habit_model.dart';
import '../../../shared/services/storage_service.dart';

class StatisticsProvider extends ChangeNotifier {
  StatisticsProvider({required StorageService storageService});

  List<Habit> _habits = [];

  void updateFromHabits(List<Habit> habits) {
    _habits = habits;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // TOTALES ACUMULADOS
  // ---------------------------------------------------------------------------

  double get totalWater  => _habits.fold(0, (s, h) => s + h.totalWaterSaved);
  double get totalCo2    => _habits.fold(0, (s, h) => s + h.totalCo2Saved);
  double get totalEnergy => _habits.fold(0, (s, h) => s + h.totalEnergySaved);
  double get totalWaste  => _habits.fold(0, (s, h) => s + h.totalWasteReduced);

  int get totalCompletions =>
      _habits.fold(0, (s, h) => s + h.totalCompletions);

  // ---------------------------------------------------------------------------
  // EQUIVALENCIAS VISUALES (para hacer el impacto comprensible)
  // ---------------------------------------------------------------------------

  /// Botellas de 500ml equivalentes al agua ahorrada.
  int get waterBottles => (totalWater / 0.5).floor();

  /// Kilómetros equivalentes al CO₂ ahorrado (0.21 kgCO2/km promedio coche).
  int get co2CarKm => (totalCo2 / 0.21).floor();

  /// Horas de televisión equivalentes a la energía ahorrada (~0.1 kWh/h).
  int get energyTvHours => (totalEnergy / 0.1).floor();

  // ---------------------------------------------------------------------------
  // HÁBITO MÁS CONSISTENTE
  // ---------------------------------------------------------------------------

  Habit? get mostConsistentHabit {
    if (_habits.isEmpty) return null;
    return _habits.reduce(
      (a, b) => a.totalCompletions >= b.totalCompletions ? a : b,
    );
  }

  // ---------------------------------------------------------------------------
  // DATOS POR CATEGORÍA (para gráfica de dona)
  // ---------------------------------------------------------------------------

  Map<HabitCategory, int> get completionsByCategory {
    final map = <HabitCategory, int>{};
    for (final h in _habits) {
      map[h.category] = (map[h.category] ?? 0) + h.totalCompletions;
    }
    return map;
  }
}
