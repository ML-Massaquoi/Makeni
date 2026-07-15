enum PrayerTime {
  morning('Morning Prayer', 7),
  midday('Angelus', 11),
  evening('Evening Prayer', 10),
  night('Night Prayer', 10);

  final String title;
  final int defaultPage;
  const PrayerTime(this.title, this.defaultPage);
}

class DailyPrayerService {
  DailyPrayerService();

  PrayerTime get currentPrayerTime {
    final hour = DateTime.now().hour;
    if (hour < 5) return PrayerTime.night;
    if (hour < 12) return PrayerTime.morning;
    if (hour < 17) return PrayerTime.midday;
    if (hour < 20) return PrayerTime.evening;
    return PrayerTime.night;
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get subtitle {
    final time = currentPrayerTime;
    switch (time) {
      case PrayerTime.morning:
        return 'Begin your day with thanksgiving and trust.';
      case PrayerTime.midday:
        return 'Pause and remember the Lord at midday.';
      case PrayerTime.evening:
        return 'Close your day in grateful prayer.';
      case PrayerTime.night:
        return 'Entrust your night to the Lord.';
    }
  }

  String get prayerTitle => currentPrayerTime.title;

  int get prayerPage => currentPrayerTime.defaultPage;
}
