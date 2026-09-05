import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_notification.dart';
import '../models/user_profile.dart';
import '../models/revision_card.dart';
import '../services/notification_service.dart';

/// Manages the in-app notification feed and reminder settings.
///
/// The feed is persisted locally via Hive. Settings (enabled features,
/// reminder time) control which scheduled local notifications are active.
class NotificationProvider extends ChangeNotifier {
  final _notifications = NotificationService.instance;

  static const _feedBoxName = 'app_notifications';
  static const _settingsBoxName = 'notification_settings';

  late final Box _feedBox;
  late final Box _settingsBox;

  List<AppNotification> _feed = [];
  bool _initialized = false;

  // Settings
  bool _dailyReminderEnabled = true;
  bool _streakReminderEnabled = true;
  bool _revisionDueEnabled = true;
  bool _recommendationEnabled = true;
  int _reminderHour = 18; // 6 PM default
  int _reminderMinute = 0;

  List<AppNotification> get feed => List.unmodifiable(
      _feed..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  bool get initialized => _initialized;

  bool get dailyReminderEnabled => _dailyReminderEnabled;
  bool get streakReminderEnabled => _streakReminderEnabled;
  bool get revisionDueEnabled => _revisionDueEnabled;
  bool get recommendationEnabled => _recommendationEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  int get unreadCount => _feed.where((n) => !n.read).length;

  Future<void> initialize() async {
    if (_initialized) return;

    await _notifications.initialize();

    _feedBox = Hive.box(_feedBoxName);
    _settingsBox = Hive.box(_settingsBoxName);

    _loadSettings();
    final rawFeed = (_feedBox.get('feed') as List<dynamic>?) ?? <dynamic>[];
    _feed = rawFeed
        .map((e) => AppNotification.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    // Apply the daily repeating reminder based on saved settings.
    await _applySchedule();

    _initialized = true;
    notifyListeners();
  }

  void _loadSettings() {
    _dailyReminderEnabled =
        _settingsBox.get('dailyReminderEnabled', defaultValue: true);
    _streakReminderEnabled =
        _settingsBox.get('streakReminderEnabled', defaultValue: true);
    _revisionDueEnabled =
        _settingsBox.get('revisionDueEnabled', defaultValue: true);
    _recommendationEnabled =
        _settingsBox.get('recommendationEnabled', defaultValue: true);
    _reminderHour = _settingsBox.get('reminderHour', defaultValue: 18);
    _reminderMinute = _settingsBox.get('reminderMinute', defaultValue: 0);
  }

  // ── Feed actions ──────────────────────────────────────────────

  Future<void> addNotification(String type, String title, String body,
      {bool alsoTray = true, DateTime? time}) async {
    final n = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      body: body,
      createdAt: time ?? DateTime.now(),
    );

    if (alsoTray && _trayEnabledFor(type)) {
      await _notifications.showImmediate(n);
    }

    _feed.insert(0, n);
    if (_feed.length > 100) _feed.removeRange(100, _feed.length);
    await _persistFeed();
    notifyListeners();
  }

  bool _trayEnabledFor(String type) {
    switch (type) {
      case 'revision':
        return _revisionDueEnabled;
      case 'streak':
        return _streakReminderEnabled;
      case 'recommendation':
      case 'learning_path':
        return _recommendationEnabled;
      default:
        return true;
    }
  }

  Future<void> markRead(String id) async {
    final index = _feed.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _feed[index] = _feed[index].copyWith(read: true);
    await _persistFeed();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    _feed = _feed.map((n) => n.copyWith(read: true)).toList();
    await _persistFeed();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _feed = [];
    await _feedBox.delete('feed');
    notifyListeners();
  }

  Future<void> _persistFeed() async {
    await _feedBox.put(
      'feed',
      _feed.map((n) => n.toMap()).toList(),
    );
  }

  // ── Settings actions ──────────────────────────────────────────

  Future<void> setDailyReminderEnabled(bool value) async {
    _dailyReminderEnabled = value;
    await _settingsBox.put('dailyReminderEnabled', value);
    await _applySchedule();
    notifyListeners();
  }

  Future<void> setStreakReminderEnabled(bool value) async {
    _streakReminderEnabled = value;
    await _settingsBox.put('streakReminderEnabled', value);
    notifyListeners();
  }

  Future<void> setRevisionDueEnabled(bool value) async {
    _revisionDueEnabled = value;
    await _settingsBox.put('revisionDueEnabled', value);
    notifyListeners();
  }

  Future<void> setRecommendationEnabled(bool value) async {
    _recommendationEnabled = value;
    await _settingsBox.put('recommendationEnabled', value);
    notifyListeners();
  }

  Future<void> setReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;
    await _settingsBox.put('reminderHour', hour);
    await _settingsBox.put('reminderMinute', minute);
    await _applySchedule();
    notifyListeners();
  }

  /// Applies the currently-enabled scheduled reminders.
  Future<void> _applySchedule() async {
    if (_dailyReminderEnabled) {
      await _notifications.scheduleDailyRevisionReminder(
        hour: _reminderHour,
        minute: _reminderMinute,
      );
    } else {
      await _notifications.cancelReminder(1001);
    }
  }

  // Guards so time-based notifications aren't re-posted on every refresh.
  bool _revisionNotified = false;
  bool _streakNotified = false;
  bool _recommendationNotified = false;

  /// Guards whether a given type was already posted this session.
  bool get revisionDueNotified => _revisionNotified;
  bool get streakNotified => _streakNotified;
  bool get recommendationNotified => _recommendationNotified;

  /// True if a revision-due notification has not yet been posted this session.
  bool get shouldNotifyRevisionDue => _revisionDueEnabled && !_revisionNotified;

  /// Marks a notification type as already posted this session.
  void markNotified(String type) {
    switch (type) {
      case 'revision':
        _revisionNotified = true;
      case 'streak':
        _streakNotified = true;
      case 'recommendation':
        _recommendationNotified = true;
    }
  }

  /// Dynamically schedules on-device alerts from live data:
  ///  1. the daily revision reminder — SKIPPED today if the user already
  ///     practiced, otherwise scheduled for the next reminder time
  ///  2. the next not-yet-due revision card fires at its exact [nextReview] time
  ///  3. a streak-saver nudge this evening IF a streak is active
  ///  4. a weekly recommendation nudge
  ///
  /// Called on every app open (and on pull-to-refresh) so schedules always
  /// reflect the user's current state.
  Future<void> scheduleDynamicReminders({
    required UserProfile? profile,
    required List<RevisionCard> cards,
    required bool practicedToday,
  }) async {
    final now = DateTime.now();

    // 1. Daily revision reminder — dynamic: skip today if already practiced.
    if (_dailyReminderEnabled) {
      if (practicedToday) {
        await _notifications.scheduleDailyRevisionReminder(
          hour: _reminderHour,
          minute: _reminderMinute,
          from: now.add(const Duration(days: 1)),
        );
        print('AlgoForge: practiced today — daily reminder moved to tomorrow');
      } else {
        await _notifications.scheduleDailyRevisionReminder(
          hour: _reminderHour,
          minute: _reminderMinute,
          from: now,
        );
        print('AlgoForge: no practice yet today — daily reminder set for today');
      }
    } else {
      await _notifications.cancelReminder(1001);
    }

    // 2. Next upcoming revision card → exact due time
    if (_revisionDueEnabled) {
      final futureCards = cards
          .where((c) => c.nextReview.isAfter(now))
          .toList()
        ..sort((a, b) => a.nextReview.compareTo(b.nextReview));
      if (futureCards.isNotEmpty) {
        final next = futureCards.first;
        print('AlgoForge: scheduling revision-due for ${next.nextReview}');
        await _notifications.scheduleRevisionDue(
          next.nextReview,
          title: 'Revision due: ${next.problemTitle}',
          body:
              'This card is due now. Tap to review ${next.problemTitle} before your next session.',
        );
      }
    }

    // 3. Streak saver — only if user has an active streak AND hasn't
    //    practiced yet today (a completed session already saves the streak)
    if (_streakReminderEnabled &&
        !practicedToday &&
        profile != null &&
        profile.streak > 0) {
      var nudge = DateTime(
        now.year,
        now.month,
        now.day,
        _reminderHour,
        _reminderMinute,
      );
      if (nudge.isBefore(now)) {
        // If reminder time already passed today, nudge in 45 minutes instead
        nudge = now.add(const Duration(minutes: 45));
      }
      print('AlgoForge: scheduling streak-saver for $nudge');
      await _notifications.scheduleStreakReminder(
        nudge,
        title: 'Don\'t break your ${profile.streak}-day streak! 🔥',
        body:
            'Solve one problem today to keep your streak alive. Your queue is one tap away.',
      );
    } else {
      await _notifications.cancelReminder(1002);
    }

    // 4. Recommendation nudge — weekly, re-created on each app open
    if (_recommendationEnabled) {
      await _notifications.scheduleRecommendationReminder(from: now);
    }
  }

  /// Sends an immediate local test notification (for verifying setup).
  Future<void> sendTestNotification() async {
    await _notifications.showTestNotification();
  }
}
