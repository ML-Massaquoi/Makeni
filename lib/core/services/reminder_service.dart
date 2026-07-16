import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../storage/local_storage.dart';

class ReminderService {
  final LocalStorage _storage;
  final FlutterLocalNotificationsPlugin _plugin;

  ReminderService(this._storage)
      : _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: settings);
  }

  Future<void> scheduleReminders() async {
    await cancelAll();

    if (!_storage.getReminderEnabled()) return;

    final times = _storage.getReminderTimes();
    for (final timeStr in times) {
      final parts = timeStr.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      final androidDetails = AndroidNotificationDetails(
        'prayer_reminder',
        'Prayer Reminders',
        channelDescription: 'Daily prayer time reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
      final details = NotificationDetails(android: androidDetails);

      await _plugin.periodicallyShow(
        id: hour * 100 + minute,
        title: 'Time to Pray',
        body: 'Open your Makeni Prayer & Hymn for $timeStr prayer.',
        repeatInterval: RepeatInterval.daily,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
