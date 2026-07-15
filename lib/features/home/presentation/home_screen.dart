import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/routes.dart';
import '../../../core/database/data_repository.dart';
import '../../../core/database/models/content_item.dart';
import '../../../core/design_system/app_typography.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/daily_prayer_service.dart';
import '../../../core/storage/local_storage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<DataRepository>();
    final storage = getIt<LocalStorage>();
    final dailyPrayer = getIt<DailyPrayerService>();

    final lastReadId = storage.getLastReadContentId();
    ContentItem? lastReadItem;
    if (lastReadId != null) {
      lastReadItem = repo.getContentById(lastReadId);
    }

    final now = DateTime.now();
    final dateStr = _formatDate(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Greeting header
              _buildGreeting(dailyPrayer, dateStr),
              const SizedBox(height: 20),

              // Continue Reading
              if (lastReadItem != null)
                _buildContinueReading(context, lastReadItem, storage),
              if (lastReadItem != null) const SizedBox(height: 20),

              // Today's Prayer card
              _buildTodayPrayer(context, dailyPrayer),
              const SizedBox(height: 20),

              // Quick Actions grid
              _buildQuickActions(context),
              const SizedBox(height: 20),

              // Categories
              _buildCategories(context),
              const SizedBox(height: 20),

              // Liturgical Season
              _buildLiturgicalSeason(),
              const SizedBox(height: 20),

              // My Favorites
              _buildMyFavorites(context, storage),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month]} ${date.year}';
  }

  // ─── Adaptive Greeting ───
  Widget _buildGreeting(DailyPrayerService dailyPrayer, String dateStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dailyPrayer.greeting,
          style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          dailyPrayer.subtitle,
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  // ─── Continue Reading ───
  Widget _buildContinueReading(
      BuildContext context, ContentItem item, LocalStorage storage) {
    final section = getIt<DataRepository>().getSectionById(item.section);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue Reading',
          style: AppTypography.heading5.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push('${Routes.reader}/${item.id}'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
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
                // Progress circle
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 0.62,
                        strokeWidth: 4,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                      const Center(
                        child: Text(
                          '62%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${section?.title ?? ''} • Last read 2 min ago',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
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

  // ─── Today's Prayer Card ───
  Widget _buildTodayPrayer(BuildContext context, DailyPrayerService dailyPrayer) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Patroness background
            Image.asset(
              'assets/images/fatima_patroness.png',
              fit: BoxFit.fitWidth,
              alignment: const Alignment(0.0, 0.0),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.92),
                    AppColors.primary.withValues(alpha: 0.75),
                    AppColors.primary.withValues(alpha: 0.90),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Today's Prayer",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Bible quote
                  const Text(
                    '"I am with you always,\nto the close of the age."',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Matthew 28:20',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Quick Actions Grid ───
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction('Holy Mass', Icons.church_rounded, Routes.library),
      _QuickAction('Rosary', Icons.circle_outlined, Routes.rosary),
      _QuickAction('Hymns', Icons.music_note_rounded, Routes.library),
      _QuickAction('Bookmarks', Icons.bookmark_rounded, Routes.workspace),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.heading5.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => context.go(action.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(action.icon, color: AppColors.accent, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Categories ───
  Widget _buildCategories(BuildContext context) {
    final categories = [
      _Category('Holy Mass', Icons.church_rounded, AppColors.primary),
      _Category('Rosary', Icons.circle_outlined, AppColors.accent),
      _Category('Morning Prayer', Icons.wb_sunny_outlined, AppColors.palmGreen),
      _Category('Evening Prayer', Icons.nights_stay_outlined, AppColors.primary),
      _Category('Sacraments', Icons.water_drop_outlined, AppColors.accent),
      _Category('Hymns', Icons.music_note_rounded, AppColors.palmGreen),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: AppTypography.heading5.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((cat) {
            return GestureDetector(
              onTap: () => context.go(Routes.library),
              child: Container(
                width: (MediaQuery.of(context).size.width - 50) / 2,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cat.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Liturgical Season ───
  Widget _buildLiturgicalSeason() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.palmGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.palmGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.palmGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco_rounded, color: AppColors.palmGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liturgical Season',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ordinary Time',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }

  // ─── My Favorites ───
  Widget _buildMyFavorites(BuildContext context, LocalStorage storage) {
    final repo = getIt<DataRepository>();
    final bookmarks = storage.getBookmarks();
    final favoriteItems = bookmarks
        .take(3)
        .map((id) => repo.getContentById(id))
        .where((item) => item != null)
        .toList();

    if (favoriteItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Favorites',
              style: AppTypography.heading5.copyWith(color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => context.go(Routes.workspace),
              child: Text(
                'See all',
                style: AppTypography.labelSmall.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...favoriteItems.whereType<ContentItem>().map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => context.push('${Routes.reader}/${item.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.bookmark,
                            color: AppColors.accent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Saved prayer',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

// ─── Data Models ───
class _QuickAction {
  final String label;
  final IconData icon;
  final String route;
  _QuickAction(this.label, this.icon, this.route);
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  _Category(this.label, this.icon, this.color);
}
