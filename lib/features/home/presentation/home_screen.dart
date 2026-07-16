import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/routes.dart';
import '../../../core/database/data_repository.dart';
import '../../../core/database/models/content_item.dart';
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

    final bookmarks = storage.getBookmarks();
    final history = storage.getReadingHistory();
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Hero Header with Cathedral Background
          SliverToBoxAdapter(
            child: _buildHeroHeader(context, dailyPrayer, dateStr),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: _buildStatsRow(bookmarks.length, history.length),
          ),

          // Continue Reading
          if (lastReadItem != null)
            SliverToBoxAdapter(
              child: _buildContinueReading(context, lastReadItem, storage),
            ),

          // Today's Prayer Hero Card
          SliverToBoxAdapter(
            child: _buildTodayPrayer(context),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: _buildQuickActions(context),
          ),

          // Categories
          SliverToBoxAdapter(
            child: _buildCategories(context),
          ),

          // My Favorites
          SliverToBoxAdapter(
            child: _buildMyFavorites(context, storage),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
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

  // ─── Hero Header with Cathedral Background ───
  Widget _buildHeroHeader(BuildContext context, DailyPrayerService dailyPrayer, String dateStr) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Stack(
        children: [
          // Cathedral background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/gpt_crops/cathedral_hero.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.3),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryDark.withValues(alpha: 0.3),
                    AppColors.primary,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: menu + crest + notification
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, size: 26),
                      color: Colors.white,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                    const SizedBox(width: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/makeni_crest.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Makeni Prayer & Hymn Book',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Diocese of Makeni',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Greeting
                Text(
                  dailyPrayer.greeting,
                  style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dailyPrayer.subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ───
  Widget _buildStatsRow(int bookmarksCount, int historyCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.book_outlined,
            label: 'Prayers',
            count: '224',
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.bookmark_outline,
            label: 'Saved',
            count: '$bookmarksCount',
            color: AppColors.accent,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.history,
            label: 'Read',
            count: '$historyCount',
            color: AppColors.palmGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Continue Reading ───
  Widget _buildContinueReading(BuildContext context, ContentItem item, LocalStorage storage) {
    final section = getIt<DataRepository>().getSectionById(item.section);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Continue Reading',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('${Routes.reader}/${item.id}'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Progress circle
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: 0.62,
                          strokeWidth: 4,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        const Center(
                          child: Text(
                            '62%',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${section?.title ?? ''} • Last read 2 min ago',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Today's Prayer Hero Card ───
  Widget _buildTodayPrayer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => context.push('${Routes.reader}/lord_prayer'),
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fatima background
                Image.asset(
                  'assets/images/gpt_crops/fatima_portrait.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, 0.0),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryDark.withValues(alpha: 0.7),
                        AppColors.primary.withValues(alpha: 0.5),
                        AppColors.primaryDark.withValues(alpha: 0.8),
                      ],
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
                      Row(
                        children: [
                          Text(
                            'Matthew 28:20',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Read Now',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Quick Actions ───
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction('Holy Mass', Icons.church_rounded, AppColors.primary, Routes.library),
      _QuickAction('Rosary', Icons.circle_outlined, AppColors.accent, Routes.rosary),
      _QuickAction('Hymns', Icons.music_note_rounded, AppColors.palmGreen, Routes.library),
      _QuickAction('Bookmarks', Icons.bookmark_rounded, AppColors.earthBrown, Routes.workspace),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: action.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(action.icon, color: action.color, size: 24),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            action.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
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
      ),
    );
  }

  // ─── Categories ───
  Widget _buildCategories(BuildContext context) {
    final categories = [
      _Category('Holy Mass', Icons.church_rounded, AppColors.primary),
      _Category('Rosary', Icons.circle_outlined, AppColors.accent),
      _Category('Morning Prayer', Icons.wb_sunny_outlined, AppColors.palmGreen),
      _Category('Evening Prayer', Icons.nights_stay_outlined, AppColors.primaryLight),
      _Category('Sacraments', Icons.water_drop_outlined, AppColors.accent),
      _Category('Hymns', Icons.music_note_rounded, AppColors.palmGreen),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
                        width: 38,
                        height: 38,
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
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Favorites',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go(Routes.workspace),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
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
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bookmark,
                              color: AppColors.primary,
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
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Saved prayer',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  _QuickAction(this.label, this.icon, this.color, this.route);
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  _Category(this.label, this.icon, this.color);
}
