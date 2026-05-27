// =============================================================================
// habit_repository.dart — Capa de acceso a datos para Hábitos
// =============================================================================
// Aísla la lógica de serialización/deserialización del provider.
// Sigue el patrón Repository: el provider sólo ve objetos de dominio (Habit).
// =============================================================================

import '../models/habit_model.dart';
import '../../../shared/services/storage_service.dart';

class HabitRepository {
  const HabitRepository(this._storage);

  final StorageService _storage;

  /// Lee todos los hábitos desde el almacenamiento local.
  List<Habit> getAll() {
    try {
      return _storage
          .readHabits()
          .map(Habit.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persiste la lista completa de hábitos.
  Future<bool> saveAll(List<Habit> habits) =>
      _storage.saveHabits(habits.map((h) => h.toJson()).toList());
}
