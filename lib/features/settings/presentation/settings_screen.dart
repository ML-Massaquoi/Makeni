import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = getIt<LocalStorage>();
  final _themeNotifier = getIt<ThemeNotifier>();
  late double _fontScale;

  @override
  void initState() {
    super.initState();
    _fontScale = _storage.getFontScale();
  }

  void _setTheme(ThemePreference theme) {
    _themeNotifier.setTheme(theme);
  }

  void _setFontScale(double scale) {
    _storage.setFontScale(scale);
    setState(() => _fontScale = scale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildThemeSection(),
              const SizedBox(height: 24),
              _buildFontSection(),
              const SizedBox(height: 24),
              _buildRemindersSection(),
              const SizedBox(height: 24),
              _buildAboutSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    final themes = [
      (ThemePreference.light, 'Light', Icons.light_mode, 'Clean, bright reading'),
      (ThemePreference.dark, 'Dark', Icons.dark_mode, 'Easy on the eyes'),
      (ThemePreference.sepia, 'Sepia', Icons.wb_twilight, 'Warm, book-like'),
      (ThemePreference.amoled, 'AMOLED', Icons.contrast, 'Deep blacks'),
    ];

    return _buildSection(
      title: 'Reading Theme',
      children: [
        ...themes.map((t) => _buildThemeOption(t.$1, t.$2, t.$3, t.$4)),
      ],
    );
  }

  Widget _buildThemeOption(
      ThemePreference theme, String label, IconData icon, String description) {
    final isSelected = _themeNotifier.currentTheme == theme;
    return InkWell(
      onTap: () => _setTheme(theme),
      borderRadius: BorderRadius.circular(Spacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 20),
            ),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSection() {
    return _buildSection(
      title: 'Font Size',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.text_fields, color: AppColors.textSecondary, size: 18),
                  Text(
                    '${(_fontScale * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.text_fields, color: AppColors.textSecondary, size: 26),
                ],
              ),
              Slider(
                value: _fontScale,
                min: 0.7,
                max: 1.6,
                divisions: 9,
                activeColor: AppColors.primary,
                onChanged: _setFontScale,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('A', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  Text('A', style: TextStyle(fontSize: 24, color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersSection() {
    return _buildSection(
      title: 'Notifications',
      children: [
        InkWell(
          onTap: () => context.push('/reminders'),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: Spacing.lg),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prayer Reminders',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Schedule daily prayer notifications',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      children: [
        _buildInfoRow('App Name', AppConfig.appName),
        const Divider(height: 1, color: AppColors.divider),
        _buildInfoRow('Version', AppConfig.appVersion),
        const Divider(height: 1, color: AppColors.divider),
        _buildInfoRow('Book', '${AppConfig.bookTitle}, ${AppConfig.bookSubtitle}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg, vertical: Spacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
