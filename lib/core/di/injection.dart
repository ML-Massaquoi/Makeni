import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../database/data_repository.dart';
import '../services/daily_prayer_service.dart';
import '../services/reminder_service.dart';
import '../storage/local_storage.dart';
import '../theme/theme_notifier.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  debugPrint('Initializing dependencies...');

  final localStorage = LocalStorage();
  await localStorage.initialize();
  getIt.registerSingleton<LocalStorage>(localStorage);
  debugPrint('LocalStorage initialized');

  getIt.registerSingleton<ThemeNotifier>(ThemeNotifier(localStorage));
  debugPrint('ThemeNotifier initialized');

  final dataRepository = DataRepository();
  await dataRepository.initialize();
  getIt.registerSingleton<DataRepository>(dataRepository);
  debugPrint('DataRepository initialized');

  getIt.registerSingleton<DailyPrayerService>(DailyPrayerService());
  debugPrint('DailyPrayerService initialized');

  final reminderService = ReminderService(localStorage);
  await reminderService.initialize();
  getIt.registerSingleton<ReminderService>(reminderService);
  debugPrint('ReminderService initialized');

  debugPrint('All dependencies initialized successfully');
}
