// =============================================================================
// date_utils.dart — Utilidades de fecha para EcoHabit
// =============================================================================

import 'package:intl/intl.dart';

abstract final class EcoDateUtils {
  // Offset para modo demostración/testing (+N días sobre la fecha real).
  static int _dayOffset = 0;

  static int get simulatedDayOffset => _dayOffset;

  /// Avanza la fecha simulada un día (para demos y testing).
  static void advanceDay() => _dayOffset++;

  /// Restablece la fecha simulada a la fecha real actual.
  static void resetSimulation() => _dayOffset = 0;

  /// Convierte una fecha a la clave de almacenamiento 'yyyy-MM-dd'.
  static String toKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// Fecha de hoy sin hora. Si hay offset activo, devuelve la fecha simulada.
  static DateTime today() {
    final n = DateTime.now().add(Duration(days: _dayOffset));
    return DateTime(n.year, n.month, n.day);
  }

  /// Índice 0-6 (Lun-Dom) desde DateTime.weekday (1=Lun, 7=Dom).
  static int weekdayIndex(DateTime date) => date.weekday - 1;

  /// Nombre completo del día de la semana en español.
  static String weekdayName(int weekday) {
    const n = ['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'];
    return n[(weekday - 1) % 7];
  }

  /// Inicial del día para gráficas (L, M, X, J, V, S, D).
  static String shortWeekday(int weekday) {
    const n = ['L','M','X','J','V','S','D'];
    return n[(weekday - 1) % 7];
  }

  /// Nombre del mes en español.
  static String monthName(int month) {
    const n = ['enero','febrero','marzo','abril','mayo','junio',
                'julio','agosto','septiembre','octubre','noviembre','diciembre'];
    return n[month - 1];
  }

  /// "Lunes, 26 de mayo" — encabezado de HomeScreen.
  static String friendlyDate(DateTime date) {
    return '${weekdayName(date.weekday)}, ${date.day} de ${monthName(date.month)}';
  }

  /// Lunes de la semana actual.
  static DateTime startOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  /// Lista de los 7 días de la semana actual (Lun–Dom).
  static List<DateTime> currentWeekDays() {
    final monday = startOfWeek(today());
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }
}
