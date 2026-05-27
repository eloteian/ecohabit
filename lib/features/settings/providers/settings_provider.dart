// =============================================================================
// settings_provider.dart — Configuración de la app con notificaciones reales
// =============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required this.storageService,
    required this.notificationService,
  });

  final StorageService storageService;
  final NotificationService notificationService;

  bool _notificationsEnabled = true;
  int _reminderHour = 20;
  int _reminderMinute = 0;
  bool _isDarkMode = false;

  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  bool get isDarkMode => _isDarkMode;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: _reminderHour, minute: _reminderMinute);

  // ---------------------------------------------------------------------------
  // CARGA
  // ---------------------------------------------------------------------------

  Future<void> loadSettings() async {
    final data = storageService.readSettings();
    _notificationsEnabled = (data['notifications'] as bool?) ?? true;
    _reminderHour = (data['reminderHour'] as int?) ?? 20;
    _reminderMinute = (data['reminderMinute'] as int?) ?? 0;
    _isDarkMode = (data['isDarkMode'] as bool?) ?? false;
    notifyListeners();

    if (_notificationsEnabled) {
      await _schedule();
    }
  }

  // ---------------------------------------------------------------------------
  // TOGGLE NOTIFICACIONES
  // ---------------------------------------------------------------------------

  Future<bool> toggleNotifications(bool value, BuildContext context) async {
    if (value) {
      final granted = await notificationService.requestPermission();
      if (!granted) return false; // no cambia el estado si se deniega
    }

    _notificationsEnabled = value;
    await _persist();
    notifyListeners();

    if (value) {
      await _schedule();
    } else {
      await notificationService.cancelAll();
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // CAMBIAR HORA DE RECORDATORIO
  // ---------------------------------------------------------------------------

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;
    await _persist();
    notifyListeners();

    if (_notificationsEnabled) {
      await _schedule();
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS PRIVADOS
  // ---------------------------------------------------------------------------

  Future<void> _schedule() async {
    await notificationService.scheduleDailyReminder(
      hour: _reminderHour,
      minute: _reminderMinute,
    );
  }

  Future<void> _persist() async {
    await storageService.saveSettings({
      'notifications': _notificationsEnabled,
      'reminderHour': _reminderHour,
      'reminderMinute': _reminderMinute,
      'isDarkMode': _isDarkMode,
    });
  }

  // ---------------------------------------------------------------------------
  // RESET (llamado desde resetAllData)
  // ---------------------------------------------------------------------------

  Future<void> resetNotifications() async {
    await notificationService.cancelAll();
    _notificationsEnabled = false;
    await _persist();
    notifyListeners();
  }
}
