import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/routes.dart';
import '../../../core/database/data_repository.dart';
import '../../../core/database/models/models.dart';
import '../../../core/di/injection.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _repo = getIt<DataRepository>();
  final _focusNode = FocusNode();

  List<SearchEntry> _results = [];
  int _selectedTab = 0;
  bool _hasSearched = false;
  List<String> _recentSearches = [
    'Lord\'s Prayer',
    'Hail Mary',
    'Glory Be',
    'Act of Contrition',
  ];

  static const _tabs = ['All', 'Prayers', 'Hymns'];

  static const _popularSearches = [
    ('The Lord\'s Prayer', Icons.mosque_rounded, AppColors.primary),
    ('Hail Mary', Icons.favorite_rounded, AppColors.accent),
    ('Glory Be', Icons.star_rounded, AppColors.palmGreen),
    ('Act of Contrition', Icons.auto_stories_rounded, Color(0xFF7B61A5)),
    ('Morning Prayer', Icons.wb_sunny_rounded, Color(0xFFE8952E)),
    ('Evening Prayer', Icons.nights_stay_rounded, Color(0xFF5B6ABF)),
  ];

  static const _quickCategories = [
    ('Rosary', Icons.circle_outlined, AppColors.primary),
    ('Mass', Icons.church_rounded, AppColors.accent),
    ('Sacraments', Icons.water_drop_rounded, AppColors.palmGreen),
    ('Hymns', Icons.music_note_rounded, Color(0xFFE8952E)),
    ('Novenas', Icons.favorite_outline, Color(0xFFD45B6A)),
    ('Litanies', Icons.format_list_numbered_rounded, AppColors.earthBrown),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    // Load from local storage in a real app
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _hasSearched = query.isNotEmpty;
      if (query.isEmpty) {
        _results = [];
        return;
      }

      final lower = query.toLowerCase().trim();
      final allEntries = _repo.getAllSearchEntries();
      _results = allEntries.where((e) {
        final title = e.title.toLowerCase();
        final keywords = e.keywords.map((k) => k.toLowerCase()).join(' ');
        final combined = '$title $keywords';
        if (title.contains(lower)) return true;
        if (combined.contains(lower)) return true;
        if (lower.split(' ').any((w) => w.length > 2 && title.contains(w))) return true;
        if (lower.split(' ').any((w) => w.length > 2 && combined.contains(w))) return true;
        if ('${e.pageNumber}'.contains(lower)) return true;
        if (e.hymnNumber != null && '${e.hymnNumber}'.contains(lower)) return true;
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
      _addToRecent(entry.title);
      context.push('${Routes.reader}/${entry.contentId}');
    } else if (entry.hymnNumber != null) {
      _addToRecent(entry.title);
      context.push('${Routes.readerHymn}/${entry.hymnNumber}');
    }
  }

  void _addToRecent(String query) {
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 6) {
        _recentSearches = _recentSearches.sublist(0, 6);
      }
    });
  }

  void _onSearchTap(String query) {
    _controller.text = query;
    _onSearchChanged(query);
    _focusNode.requestFocus();
  }

  void _clearRecent() {
    setState(() => _recentSearches.clear());
  }

  void _onClear() {
    _controller.clear();
    setState(() {
      _results = [];
      _hasSearched = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Hero Header
          _buildHeroHeader(),
          // Search Bar
          _buildSearchBar(),
          // Filter Tabs (only when searching)
          if (_hasSearched) _buildFilterBar(),
          // Content
          Expanded(
            child: _hasSearched ? _buildSearchResults() : _buildExploreContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/gpt_crops/cathedral_hero.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.3),
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
            child: Row(
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
                        'Discover',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Search prayers, hymns & more',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      color: AppColors.surface,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focusNode.hasFocus ? AppColors.primary : AppColors.divider,
            width: _focusNode.hasFocus ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: _hasSearched ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search prayers, hymns, keywords...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_hasSearched)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textTertiary,
                onPressed: _onClear,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedTab == index;
          return Padding(
            padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Search Results ───
  Widget _buildSearchResults() {
    final filtered = _filteredResults();

    if (filtered.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        final isHymn = entry.contentType == 'hymn';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _onResultTap(entry),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
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
                      color: (isHymn ? AppColors.accent : AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHymn ? Icons.music_note_rounded : Icons.auto_stories_rounded,
                      color: isHymn ? AppColors.accent : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Page ${entry.pageNumber}${isHymn && entry.hymnNumber != null ? ' • Hymn ${entry.hymnNumber}' : ''}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isHymn ? AppColors.accent : AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isHymn ? 'Hymn' : 'Prayer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isHymn ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
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
            child: Icon(Icons.search_off_rounded, size: 36, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No results found',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
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

  // ─── Explore Content (when not searching) ───
  Widget _buildExploreContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('Recent Searches', onClear: _clearRecent),
            const SizedBox(height: 12),
            _buildRecentSearches(),
            const SizedBox(height: 24),
          ],

          // Popular Searches
          _buildSectionHeader('Popular Prayers'),
          const SizedBox(height: 12),
          _buildPopularSearches(),
          const SizedBox(height: 24),

          // Quick Categories
          _buildSectionHeader('Browse by Category'),
          const SizedBox(height: 12),
          _buildQuickCategories(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (onClear != null)
          GestureDetector(
            onTap: onClear,
            child: const Text(
              'Clear all',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _recentSearches.map((search) {
        return GestureDetector(
          onTap: () => _onSearchTap(search),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    search,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPopularSearches() {
    return Column(
      children: _popularSearches.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _onSearchTap(item.$1),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
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
                      color: item.$3.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.$2, color: item.$3, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickCategories() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: _quickCategories.length,
      itemBuilder: (context, index) {
        final cat = _quickCategories[index];
        return GestureDetector(
          onTap: () => _onSearchTap(cat.$1),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cat.$3.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cat.$3.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(cat.$2, color: cat.$3, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  cat.$1,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
