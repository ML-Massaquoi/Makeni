import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/storage/local_storage.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _storage = getIt<LocalStorage>();
  final _reminderService = getIt<ReminderService>();

  late bool _enabled;
  late List<String> _times;

  @override
  void initState() {
    super.initState();
    _enabled = _storage.getReminderEnabled();
    _times = _storage.getReminderTimes();
  }

  Future<void> _toggle(bool value) async {
    await _storage.setReminderEnabled(value);
    setState(() => _enabled = value);
    if (value) {
      await _reminderService.scheduleReminders();
    } else {
      await _reminderService.cancelAll();
    }
  }

  Future<void> _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (time == null) return;
    final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (_times.contains(formatted)) return;
    _times.add(formatted);
    _times.sort();
    await _storage.setReminderTimes(_times);
    setState(() {});
    if (_enabled) await _reminderService.scheduleReminders();
  }

  Future<void> _removeTime(String time) async {
    _times.remove(time);
    await _storage.setReminderTimes(_times);
    setState(() {});
    if (_enabled) await _reminderService.scheduleReminders();
  }

  String _timeLabel(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return time;
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _prayerLabel(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return '';
    final hour = int.parse(parts[0]);
    if (hour < 5) return 'Night Prayer';
    if (hour < 12) return 'Morning Prayer';
    if (hour < 17) return 'Angelus';
    if (hour < 20) return 'Evening Prayer';
    return 'Night Prayer';
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
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: Text(
                      'Prayer Reminders',
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildEnableToggle(),
              const SizedBox(height: 24),
              if (_enabled) _buildTimeList(),
              if (_enabled) const SizedBox(height: 24),
              if (_enabled) _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnableToggle() {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reminders',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Get notified at your prayer times',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: _toggle,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeList() {
    if (_times.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.access_time,
                  size: 48,
                  color: AppColors.textTertiary.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(
                'No reminders set.\nTap below to add your prayer times.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Prayer Times',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._times.map((time) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(Spacing.lg),
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
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      ),
                      child: const Icon(Icons.access_time,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: Spacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _timeLabel(time),
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _prayerLabel(time),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeTime(time),
                      icon: const Icon(Icons.close,
                          color: AppColors.textTertiary, size: 20),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addTime,
        icon: const Icon(Icons.add),
        label: const Text('Add Prayer Time'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
          ),
        ),
      ),
    );
  }
}
