import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/routes.dart';
import '../../../core/database/data_repository.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<DataRepository>();
    final sections = repo.getAllSections()
      ..sort((a, b) => a.pageStart.compareTo(b.pageStart));

    final sectionsWithoutUnknown =
        sections.where((s) => s.id != 'unknown').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Library',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.search,
                        onPressed: () => context.go(Routes.search),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Browse all collections',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilterTabs(
                    labels: const ['All', 'Prayers', 'Hymns'],
                    selectedIndex: 0,
                    onSelected: (_) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: sectionsWithoutUnknown.length,
                itemBuilder: (context, index) {
                  final section = sectionsWithoutUnknown[index];
                  final items = repo.getContentBySection(section.id);
                  final hymnCount = items.where((c) => c.type == 'hymn').length;
                  final prayerCount = items.length - hymnCount;

                  final pageRange = section.pageStart == section.pageEnd
                      ? 'Page ${section.pageStart}'
                      : 'Pages ${section.pageStart}–${section.pageEnd}';

                  final subtitle = '$pageRange • ${prayerCount > 0 ? '$prayerCount prayer${prayerCount > 1 ? 's' : ''}' : ''}${prayerCount > 0 && hymnCount > 0 ? ', ' : ''}${hymnCount > 0 ? '$hymnCount hymn${hymnCount > 1 ? 's' : ''}' : ''}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ContentCard(
                      title: section.title,
                      subtitle: subtitle,
                      icon: _getIconForSection(section.id),
                      iconColor: _getColorForSection(section.id),
                      onTap: () => context.push(
                        '${Routes.readerPage}/${section.pageStart}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSection(String id) {
    switch (id) {
      case 'morning_prayer':
      case 'evening_prayer':
        return Icons.wb_sunny_outlined;
      case 'holy_mass':
        return Icons.church_outlined;
      case 'sacraments':
        return Icons.water_drop_outlined;
      case 'rites_blessings':
        return Icons.auto_stories_outlined;
      case 'litanies':
        return Icons.list_alt_outlined;
      case 'novenas':
        return Icons.favorite_outline;
      case 'stations':
        return Icons.signpost_outlined;
      case 'rosary':
        return Icons.water_drop_outlined;
      case 'hymns':
        return Icons.music_note_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  Color _getColorForSection(String id) {
    switch (id) {
      case 'morning_prayer':
      case 'evening_prayer':
        return const Color(0xFFFF9800);
      case 'holy_mass':
        return AppColors.accent;
      case 'sacraments':
        return const Color(0xFF4CAF50);
      case 'rites_blessings':
        return const Color(0xFF9C27B0);
      case 'litanies':
        return const Color(0xFFFF9800);
      case 'novenas':
        return const Color(0xFFE91E63);
      case 'stations':
        return const Color(0xFF795548);
      case 'rosary':
        return const Color(0xFF2196F3);
      case 'hymns':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }
}
