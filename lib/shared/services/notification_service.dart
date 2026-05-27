// =============================================================================
// notification_service.dart — Singleton para notificaciones locales diarias
// =============================================================================

import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _dailyId = 1;
  static const String _channelId = 'eco_daily_reminder';
  static const Color _kPrimary = Color(0xFF2E7D32);

  // ---------------------------------------------------------------------------
  // INICIALIZACIÓN
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );
    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // PERMISOS
  // ---------------------------------------------------------------------------

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (ios != null) {
      return await ios.requestPermissions(
              alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // PROGRAMAR / CANCELAR
  // ---------------------------------------------------------------------------

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(id: _dailyId);

    final now = tz.TZDateTime.now(tz.local);
    var fire = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (fire.isBefore(now)) {
      fire = fire.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Recordatorio diario',
      channelDescription: 'Te recuerda completar tus hábitos ecológicos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: _kPrimary,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: _dailyId,
      title: '🌿 EcoHabit',
      body: '¡Es hora de tus hábitos sostenibles! El planeta te lo agradece 🌍',
      scheduledDate: fire,
      notificationDetails: const NotificationDetails(
          android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
}
