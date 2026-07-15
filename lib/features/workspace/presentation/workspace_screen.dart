import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/routes.dart';
import '../../../core/database/data_repository.dart';
import '../../../core/database/models/content_item.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/local_storage.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final _repo = getIt<DataRepository>();
  final _storage = getIt<LocalStorage>();

  @override
  Widget build(BuildContext context) {
    final bookmarks = _storage.getBookmarks();
    final history = _storage.getReadingHistory();

    final bookmarkItems = bookmarks
        .map((id) => _repo.getContentById(id))
        .whereType<ContentItem>()
        .toList();

    final historyItems = history
        .map((id) => _repo.getContentById(id))
        .whereType<ContentItem>()
        .toList();

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
                'My Workspace',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your bookmarks and reading history',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatsRow(bookmarkItems.length, historyItems.length),
              const SizedBox(height: 24),
              if (bookmarkItems.isNotEmpty) ...[
                _buildSectionHeader('Bookmarks', bookmarks.length),
                const SizedBox(height: 12),
                ...bookmarkItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildContentRow(item, isBookmark: true),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (historyItems.isNotEmpty) ...[
                _buildSectionHeader('Recently Read', history.length),
                const SizedBox(height: 12),
                ...historyItems.take(10).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildContentRow(item),
                      ),
                    ),
                const SizedBox(height: 24),
              ],
              if (bookmarkItems.isEmpty && historyItems.isEmpty)
                _buildEmptyState(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(int bookmarksCount, int historyCount) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.bookmark_outline,
          label: 'Bookmarks',
          count: bookmarksCount,
          color: AppColors.accent,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.history,
          label: 'History',
          count: historyCount,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: Spacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '$count items',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContentRow(ContentItem item, {bool isBookmark = false}) {
    return ContentCard(
      title: item.title,
      subtitle: 'Page ${item.pageNumber}',
      icon: Icons.book_outlined,
      onTap: () {
        _storage.addToHistory(item.id);
        context.push('${Routes.reader}/${item.id}');
      },
      badge: isBookmark ? null : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            // Fatima devotion image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/fatima_square.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your prayer journey begins here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bookmark prayers and track your reading\nhistory to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
