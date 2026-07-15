import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/routes.dart';
import '../../../core/database/data_repository.dart';
import '../../../core/database/models/models.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _repo = getIt<DataRepository>();

  List<SearchEntry> _results = [];
  int _selectedTab = 0;
  bool _hasSearched = false;

  static const _tabs = ['All', 'Prayers', 'Hymns'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _hasSearched = query.isNotEmpty;
      if (query.isEmpty) {
        _results = [];
        return;
      }

      final lower = query.toLowerCase();

      final allEntries = _repo.getAllSearchEntries();
      _results = allEntries.where((e) {
        if (e.title.toLowerCase().contains(lower)) return true;
        if (e.keywords.any((k) => k.toLowerCase().contains(lower))) return true;
        if ('${e.pageNumber}'.contains(lower)) return true;
        if (e.hymnNumber != null && '${e.hymnNumber}'.contains(lower)) {
          return true;
        }
        return false;
      }).toList()
        ..sort((a, b) => b.searchWeight.compareTo(a.searchWeight));

      _results = _results.take(50).toList();
    });
  }

  List<SearchEntry> _filteredResults() {
    switch (_selectedTab) {
      case 1:
        return _results.where((e) => e.contentType == 'prayer').toList();
      case 2:
        return _results.where((e) => e.contentType == 'hymn').toList();
      default:
        return _results;
    }
  }

  void _onResultTap(SearchEntry entry) {
    final content = _repo.getContentById(entry.contentId);
    if (content != null) {
      context.push('${Routes.reader}/${entry.contentId}');
    } else if (entry.hymnNumber != null) {
      context.push('${Routes.readerHymn}/${entry.hymnNumber}');
    }
  }

  void _onClear() {
    _controller.clear();
    setState(() {
      _results = [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSearchBar(
                    controller: _controller,
                    onChanged: _onSearchChanged,
                    onFilter: () {},
                    showFilter: false,
                    onClear: _onClear,
                  ),
                  if (_hasSearched) ...[
                    const SizedBox(height: 16),
                    FilterTabs(
                      labels: _tabs,
                      selectedIndex: _selectedTab,
                      onSelected: (i) => setState(() => _selectedTab = i),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'Search prayers, hymns,\nand keywords',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredResults();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(fontSize: 16, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        final isHymn = entry.contentType == 'hymn';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ContentCard(
            title: entry.title,
            subtitle: 'Page ${entry.pageNumber}${isHymn && entry.hymnNumber != null ? ' • Hymn ${entry.hymnNumber}' : ''}',
            badge: entry.contentType == 'hymn' ? 'Hymn' : 'Prayer',
            icon: isHymn ? Icons.music_note_outlined : Icons.book_outlined,
            iconColor: isHymn ? AppColors.accent : AppColors.primary,
            onTap: () => _onResultTap(entry),
          ),
        );
      },
    );
  }
}
