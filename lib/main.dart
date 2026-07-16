import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/navigation_engine/navigation_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MakeniPrayerBookApp());
}

class MakeniPrayerBookApp extends StatefulWidget {
  const MakeniPrayerBookApp({super.key});

  @override
  State<MakeniPrayerBookApp> createState() => _MakeniPrayerBookAppState();
}

class _MakeniPrayerBookAppState extends State<MakeniPrayerBookApp> {
  final _themeNotifier = getIt<ThemeNotifier>();

  @override
  void initState() {
    super.initState();
    _themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeNotifier.currentTheme;

    return MaterialApp.router(
      title: 'Makeni Prayer and Hymn Book',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          theme == ThemePreference.sepia || theme == ThemePreference.light
              ? ThemeMode.light
              : ThemeMode.dark,
      routerConfig: NavigationHandler.router,
    );
  }
}
