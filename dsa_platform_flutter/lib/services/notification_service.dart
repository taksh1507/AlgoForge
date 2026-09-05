import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/app_notification.dart';

/// Wraps flutter_local_notifications for on-device (free) notifications.
///
/// Handles:
///  - initialization & permission requests
///  - immediate in-app notifications
///  - scheduling daily revision reminders
///  - scheduling streak/practice reminders
///  - scheduling revision-due alerts
///  - scheduling learning-path / recommendation updates
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _dailyReminderId = 1001;
  static const int _streakReminderId = 1002;
  static const int _recommendationReminderId = 1003;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initializes the plugin and requests notification permission (Android 13+).
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    _initialized = true;
  }

  bool get isInitialized => _initialized;

  // ── Immediate notification (in-app + tray) ────────────────────

  Future<void> showImmediate(AppNotification notification) async {
    if (!_initialized || !await Permission.notification.isGranted) return;
    await _plugin.show(
      notification.id.hashCode & 0x7fffffff,
      notification.title,
      notification.body,
      notificationDetails,
    );
  }

  // ── Daily revision reminder (one-off, dynamic) ────────────────

  /// Schedules a single daily revision reminder at [hour]:[minute] on
  /// the next matching day from [from]. Designed to be re-scheduled on
  /// every app open so it can skip days the user already practiced.
  Future<void> scheduleDailyRevisionReminder({
    required int hour,
    required int minute,
    DateTime? from,
  }) async {
    await _plugin.cancel(_dailyReminderId);
    final now = from ?? DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    print('AlgoForge: scheduling daily reminder at $scheduled');

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'AlgoForge — Daily Revision',
      'A few minutes of revision keeps your DSA sharp. Open your queue!',
      _toTZ(scheduled),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Streak / practice reminder ────────────────────────────────

  /// Schedules a one-off streak-saver reminder. Provide [title] & [body]
  /// for a custom message, or use the default streak reminder.
  Future<void> scheduleStreakReminder(DateTime when,
      {String title = 'Don\'t break your streak!',
      String body = 'Solve one problem today to keep the flame going. 🔥'}) async {
    await _plugin.zonedSchedule(
      _streakReminderId,
      title,
      body,
      _toTZ(when),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Revision-due alert ────────────────────────────────────────

  /// Fires [title]/[body] after [delay] (e.g. when a revision card becomes due).
  Future<void> scheduleRevisionDue(
    DateTime when, {
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      _revisionDueId(when),
      title,
      body,
      _toTZ(when),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Learning path / recommendation update ─────────────────────

  /// Schedules a one-off recommendation nudge (re-created each app open),
  /// suppressing nags if the user already has fresh recommendations.
  Future<void> scheduleRecommendationReminder({
    required DateTime from,
  }) async {
    await _plugin.cancel(_recommendationReminderId);
    final scheduled = from.add(const Duration(days: 7));
    print('AlgoForge: scheduling weekly recommendation nudge at $scheduled');
    await _plugin.zonedSchedule(
      _recommendationReminderId,
      'AlgoForge — New Recommendations',
      'Your adaptive learning path has fresh problems waiting. Check them out!',
      _toTZ(scheduled),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Management ────────────────────────────────────────────────

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancels a single scheduled notification by id.
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelRevisionDue(DateTime when) async {
    await _plugin.cancel(_revisionDueId(when));
  }

  /// Sends an immediate test notification (used to verify setup).
  Future<void> showTestNotification() async {
    if (!_initialized) return;
    final granted = await Permission.notification.isGranted;
    print('AlgoForge: test notification - permission granted: $granted');
    if (!granted) return;
    await _plugin.show(
      9999,
      'AlgoForge — Test',
      'Notifications are working. Daily revision is scheduled.',
      notificationDetails,
    );
  }

  int _revisionDueId(DateTime when) =>
      2000 + (when.millisecondsSinceEpoch % 10000);

  /// Converts a local wall-clock [DateTime] to an absolute TZDateTime.
  ///
  /// Uses [DateTime.toUtc] (Dart's local→UTC conversion) so the scheduled
  /// instant is correct on-device even though the timezone package's
  /// `tz.local` defaults to UTC.
  tz.TZDateTime _toTZ(DateTime when) =>
      tz.TZDateTime.from(when.toUtc(), tz.UTC);

  NotificationDetails get notificationDetails {
    const android = AndroidNotificationDetails(
      'algoforge_reminders',
      'AlgoForge Reminders',
      channelDescription: 'Daily revision, streak & learning reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }
}
