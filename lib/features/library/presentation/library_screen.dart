import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/routes.dart';
import '../../../core/database/data_repository.dart';
import '../../../core/di/injection.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final repo = getIt<DataRepository>();
    final allSections = repo.getAllSections()
      ..sort((a, b) => a.pageStart.compareTo(b.pageStart));

    final sections = allSections.where((s) => s.id != 'unknown').toList();

    final filteredSections = sections.where((section) {
      if (_selectedTab == 0) return true;
      final items = repo.getContentBySection(section.id);
      if (_selectedTab == 1) return items.any((c) => c.type != 'hymn');
      if (_selectedTab == 2) return items.any((c) => c.type == 'hymn');
      return true;
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          // Hero Header
          _buildHeroHeader(context),
          // Filter Tabs
          _buildFilterBar(),
          // Content
          Expanded(
            child: filteredSections.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: filteredSections.length,
                    itemBuilder: (context, index) {
                      final section = filteredSections[index];
                      final items = repo.getContentBySection(section.id);
                      final hymnCount = items.where((c) => c.type == 'hymn').length;
                      final prayerCount = items.length - hymnCount;

                      return _buildModernSectionCard(
                        context: context,
                        section: section,
                        prayerCount: prayerCount,
                        hymnCount: hymnCount,
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/gpt_crops/cathedral_hero.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.2),
              ),
            ),
          ),
          // Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryDark.withValues(alpha: 0.4),
                    AppColors.primary,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
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
                      child: Text(
                        'Prayer & Hymn Book',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            '224 Pages',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sacred Texts',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Browse the complete Makeni Prayer and Hymn Book',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          _buildFilterChip('All', 0, Icons.grid_view_rounded),
          const SizedBox(width: 8),
          _buildFilterChip('Prayers', 1, Icons.auto_stories_outlined),
          const SizedBox(width: 8),
          _buildFilterChip('Hymns', 2, Icons.music_note_rounded),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSectionCard({
    required BuildContext context,
    required dynamic section,
    required int prayerCount,
    required int hymnCount,
    required int index,
  }) {
    final color = _getSectionColor(section.id);
    final icon = _getSectionIcon(section.id);
    final totalItems = prayerCount + hymnCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('${Routes.readerPage}/${section.pageStart}'),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top section with color accent
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.12),
                      color.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    // Title + page range
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: const TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pages ${section.pageStart}–${section.pageEnd}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chevron
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
                    ),
                  ],
                ),
              ),
              // Bottom stats bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Prayer count
                    _buildStatBadge(
                      icon: Icons.auto_stories_outlined,
                      count: prayerCount,
                      label: 'Prayers',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    // Hymn count
                    if (hymnCount > 0)
                      _buildStatBadge(
                        icon: Icons.music_note_rounded,
                        count: hymnCount,
                        label: 'Hymns',
                        color: AppColors.accent,
                      ),
                    const Spacer(),
                    // Total items
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$totalItems items',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book_outlined, size: 36, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No sections found',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try selecting a different filter above',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String id) {
    switch (id) {
      case 'morning_prayer':
      case 'evening_prayer':
        return Icons.wb_sunny_rounded;
      case 'holy_mass':
        return Icons.church_rounded;
      case 'sacraments':
        return Icons.water_drop_rounded;
      case 'rites_blessings':
        return Icons.auto_stories_rounded;
      case 'litanies':
        return Icons.format_list_numbered_rounded;
      case 'novenas':
        return Icons.favorite_rounded;
      case 'stations':
        return Icons.signpost_rounded;
      case 'rosary':
        return Icons.circle_rounded;
      case 'hymns':
        return Icons.music_note_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  Color _getSectionColor(String id) {
    switch (id) {
      case 'morning_prayer':
        return const Color(0xFFE8952E);
      case 'evening_prayer':
        return const Color(0xFF5B6ABF);
      case 'holy_mass':
        return AppColors.primary;
      case 'sacraments':
        return AppColors.palmGreen;
      case 'rites_blessings':
        return const Color(0xFF7B61A5);
      case 'litanies':
        return const Color(0xFFE8952E);
      case 'novenas':
        return const Color(0xFFD45B6A);
      case 'stations':
        return AppColors.earthBrown;
      case 'rosary':
        return const Color(0xFF2196F3);
      case 'hymns':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }
}
