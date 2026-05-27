// =============================================================================
// streak_event.dart — Modelo de evento de racha para animaciones
// =============================================================================

enum StreakEventType { milestone, lost }

class StreakEvent {
  const StreakEvent(this.type, this.value);

  final StreakEventType type;

  /// Días de racha: el valor alcanzado (milestone) o el perdido (lost).
  final int value;

  bool get isMilestone => type == StreakEventType.milestone;
  bool get isLost      => type == StreakEventType.lost;
}
