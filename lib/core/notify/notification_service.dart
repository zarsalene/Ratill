import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_plan.dart';

/// Local notifications and alarms. Everything is scheduled on the phone: no
/// push service, no network.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initFuture;

  // Channel ids end in a version: Android keeps a channel's sound once it exists.
  static const _adhanChannel = 'adhan_v1';
  static const _reminderChannel = 'reminders_v1';

  Future<void> _init() => _initFuture ??= _initOnce();

  Future<void> _initOnce() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Shows the system prompt for notifications (Android 13+). Explain why
  /// before calling. True when allowed.
  Future<bool> requestPermission() async {
    await _init();
    return await _android?.requestNotificationsPermission() ?? false;
  }

  /// Exact alarms are needed for the Adhan to ring at the minute.
  Future<bool> canScheduleExact() async {
    await _init();
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  /// Opens the system screen where the reader allows exact alarms.
  Future<void> requestExactAlarms() async {
    await _init();
    await _android?.requestExactAlarmsPermission();
  }

  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }

  /// Replaces every scheduled notification with [plan]. Falls back to inexact
  /// alarms (a few minutes late) when exact alarms are not allowed.
  Future<void> schedule(
    List<Reminder> plan, {
    required String Function(Reminder) title,
    required String Function(Reminder) body,
    required String adhanChannelName,
    required String reminderChannelName,
  }) async {
    await _init();
    await _plugin.cancelAll();
    if (plan.isEmpty) return;
    final mode = await canScheduleExact() ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
    for (final r in plan) {
      final adhan = r.kind == ReminderKind.adhan;
      await _plugin.zonedSchedule(
        id: r.id,
        title: title(r),
        body: body(r),
        scheduledDate: tz.TZDateTime.from(r.time, tz.local),
        androidScheduleMode: mode,
        notificationDetails: NotificationDetails(
          android: adhan
              ? AndroidNotificationDetails(
                  _adhanChannel,
                  adhanChannelName,
                  importance: Importance.max,
                  priority: Priority.high,
                  sound: const RawResourceAndroidNotificationSound('adhan'),
                )
              : AndroidNotificationDetails(_reminderChannel, reminderChannelName),
        ),
      );
    }
  }
}
