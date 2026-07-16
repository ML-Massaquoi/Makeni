import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/database/data_repository.dart';
import '../../../core/database/models/content_item.dart';
import '../../../core/database/models/hymn.dart';
import '../../../core/design_system/components/page_image.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/content_parser.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/theme_notifier.dart';
import 'reader_reflection_sheet.dart';
import 'reader_settings_sheet.dart';

class ReaderScreen extends StatefulWidget {
  final String? contentId;
  final int? hymnNumber;
  final int? pageNumber;

  const ReaderScreen({
    super.key,
    this.contentId,
    this.hymnNumber,
    this.pageNumber,
  });

  @override
  State<ReaderScreen> createState() => ReaderScreenState();
}

class ReaderScreenState extends State<ReaderScreen> with TickerProviderStateMixin {
  final _repo = getIt<DataRepository>();
  final _storage = getIt<LocalStorage>();
  final _scrollController = ScrollController();
  final _themeNotifier = getIt<ThemeNotifier>();

  ContentItem? _content;
  Hymn? _hymn;
  String _title = '';
  bool _isBookmarked = false;
  List<ContentBlock> _parsedBlocks = [];

  double _fontScale = 1.0;
  double _lineHeight = 1.7;
  double _paragraphSpacing = 16.0;
  String _fontFamily = 'Georgia';
  String _alignment = 'justify';
  String _margin = 'normal';

  bool _headerCollapsed = false;
  bool _isSacredMode = false;
  double _progress = 0;
  int _visibleSectionIndex = 0;
  List<String> _sections = [];

  late AnimationController _toolbarAnimController;
  late Animation<double> _toolbarOpacity;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadContent();

    _toolbarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..value = 1.0;
    _toolbarOpacity = CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.easeOut,
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _toolbarAnimController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    _fontScale = _storage.getReaderFontScale();
    _lineHeight = _storage.getReaderLineHeight();
    _paragraphSpacing = _storage.getReaderParagraphSpacing();
    _fontFamily = _storage.getReaderFontFamily();
    _alignment = _storage.getReaderAlignment();
    _margin = _storage.getReaderMargin();
  }

  void _loadContent() {
    ContentItem? content;

    if (widget.contentId != null) {
      content = _repo.getContentById(widget.contentId!);
    } else if (widget.pageNumber != null) {
      content = _repo.getContentByPage(widget.pageNumber!);
    } else if (widget.hymnNumber != null) {
      final hymn = _repo.getHymnByNumber(widget.hymnNumber!);
      if (hymn != null) {
        _hymn = hymn;
        _title = 'Hymn ${hymn.hymnNumber}: ${hymn.title}';
      }
    }

    if (content != null) {
      _content = content;
      _title = content.title.isNotEmpty ? content.title : 'Page ${content.pageNumber}';
      _isBookmarked = _storage.isBookmarked(content.id);
      _storage.setLastReadContentId(content.id);
      _storage.setLastReadPage(content.pageNumber);
      _storage.addToHistory(content.id);

      _parsedBlocks = ContentParser.parse(content.text, title: content.title);
      _sections = _parsedBlocks
          .where((b) => b.type == ContentBlockType.sectionHeading)
          .map((b) => b.text)
          .toList();
    }

    if (mounted) setState(() {});
  }

  void _onScroll() {
    final pos = _scrollController.position;
    final newPos = pos.pixels;
    final newProgress = pos.maxScrollExtent > 0 ? pos.pixels / pos.maxScrollExtent : 0.0;

    setState(() {
      _progress = newProgress;
      _headerCollapsed = newPos > 80;
    });

    _updateVisibleSection();
  }

  void _updateVisibleSection() {
    if (_sections.isEmpty) return;
    for (int i = 0; i < _parsedBlocks.length; i++) {
      if (_parsedBlocks[i].type == ContentBlockType.sectionHeading) {
        _visibleSectionIndex = _sections.indexOf(_parsedBlocks[i].text);
      }
    }
  }

  void _toggleBookmark() {
    if (_content == null) return;
    HapticFeedback.lightImpact();
    if (_isBookmarked) {
      _storage.removeBookmark(_content!.id);
    } else {
      _storage.addBookmark(_content!.id);
    }
    setState(() => _isBookmarked = !_isBookmarked);
  }

  void _enterSacredMode() {
    if (_isSacredMode) return;
    setState(() => _isSacredMode = true);
    _toolbarAnimController.reverse();
  }

  void _exitSacredMode() {
    if (!_isSacredMode) return;
    setState(() => _isSacredMode = false);
    _toolbarAnimController.forward();
  }

  void _shareContent() {
    final text = _content?.text ?? _hymn?.text ?? '';
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: '$_title\n\n$text\n\n— Makeni Prayer and Hymn Book'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReaderSettingsSheet(onChanged: () {
        _loadSettings();
        if (mounted) setState(() {});
      }),
    );
  }

  void _openReflection() async {
    if (_content == null) return;
    final existing = _storage.getReflection(_content!.id);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReaderReflectionSheet(
        contentId: _content!.id,
        contentTitle: _title,
        existingReflection: existing,
      ),
    );
    if (result != null) {
      await _storage.saveReflection(_content!.id, result);
    }
  }

  void _scrollToSection(int index) {
    if (index >= _sections.length) return;
    int blockIndex = 0;
    int found = -1;
    for (int i = 0; i < _parsedBlocks.length; i++) {
      if (_parsedBlocks[i].type == ContentBlockType.sectionHeading) {
        found++;
        if (found == index) {
          blockIndex = i;
          break;
        }
      }
    }
    if (found >= 0 && _content != null) {
      final targetScroll = blockIndex * 100.0;
      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_content == null && _hymn == null) {
      return Scaffold(
        backgroundColor: _themeNotifier.currentTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Reader'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Content not found',
            style: TextStyle(fontSize: 16, color: _themeNotifier.currentTheme.secondaryTextColor),
          ),
        ),
      );
    }

    final theme = _themeNotifier.currentTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: GestureDetector(
        onTap: _isSacredMode ? _exitSacredMode : null,
        child: Stack(
          children: [
            // Main scrollable content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Collapsible header
                  _buildHeader(theme),
                  // Content area
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is UserScrollNotification && _isSacredMode) {
                          _exitSacredMode();
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: _marginPadding(),
                        child: Column(
                          crossAxisAlignment: _alignStart(),
                          children: [
                            const SizedBox(height: 24),
                            // Metadata cards
                            _buildMetadataCards(theme),
                            const SizedBox(height: 24),
                            // Page image
                            _buildPageImage(theme),
                            // Content blocks
                            if (_content != null) _buildContentBlocks(theme),
                            if (_hymn != null) _buildHymnContent(theme),
                            const SizedBox(height: 32),
                            // Footer
                            _buildFooter(theme),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            if (_progress > 0.02)
              Positioned(
                top: _headerCollapsed ? 52 : (_isSacredMode ? 0 : 100),
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _isSacredMode ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      minHeight: 2,
                    ),
                  ),
                ),
              ),

            // Floating toolbar
            if (!_isSacredMode)
              Positioned(
                right: 16,
                top: MediaQuery.of(context).padding.top + (_headerCollapsed ? 56 : 104),
                child: FadeTransition(
                  opacity: _toolbarOpacity,
                  child: _buildFloatingToolbar(theme),
                ),
              ),

            // Sacred mode hint
            if (_isSacredMode)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: _exitSacredMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tap to show controls',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemePreference theme) {
    final showDetails = !_headerCollapsed || _isSacredMode;
    final sectionName = _content != null ? _repo.getSectionById(_content!.section)?.title ?? '' : '';
    final pageNum = _content?.pageNumber ?? _hymn?.startPage ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        bottom: showDetails ? 12 : 4,
      ),
      decoration: BoxDecoration(
        color: _isSacredMode ? Colors.transparent : theme.surfaceColor,
        border: _isSacredMode
            ? null
            : Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: Column(
        children: [
          // Top row: back, title, bookmark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: theme.textColor,
                  iconSize: 20,
                ),
                Expanded(
                  child: Text(
                    _headerCollapsed ? _title : '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!_isSacredMode) ...[
                  IconButton(
                    onPressed: _toggleBookmark,
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: _isBookmarked ? AppColors.accent : theme.textColor,
                      size: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: _openSettings,
                    icon: Icon(Icons.text_fields, color: theme.textColor, size: 22),
                  ),
                ],
              ],
            ),
          ),
          // Details row: section, category, page reference
          if (showDetails && !_isSacredMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (sectionName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sectionName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  if (sectionName.isNotEmpty) const SizedBox(width: 8),
                  if (_content?.category != null && _content!.category.isNotEmpty)
                    Expanded(
                      child: Text(
                        _content!.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  if (pageNum > 0)
                    Text(
                      'p. $pageNum',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataCards(ThemePreference theme) {
    final readingTime = _content?.readingTimeMinutes ?? 1.0;
    final categoryIcon = _content?.type == 'liturgical_text'
        ? Icons.church_outlined
        : Icons.book_outlined;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _metaChip(Icons.schedule_outlined, '${readingTime.round()} min read', theme),
          _metaChip(categoryIcon, _content?.category ?? '', theme),
          _metaChip(Icons.menu_book_outlined,
              'Printed Pages ${_getPageRange()}', theme),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, ThemePreference theme) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageImage(ThemePreference theme) {
    final page = _content?.pageNumber ?? _hymn?.startPage ?? 0;
    if (page == 0 || !PageImageProvider.hasImageForPage(page)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PageImageProvider.buildImage(page),
      ),
    );
  }

  Widget _buildContentBlocks(ThemePreference theme) {
    if (_parsedBlocks.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: _paragraphSpacing),
        child: Text(
          _content!.text,
          style: _blockStyle(ContentBlockType.paragraph, theme),
          textAlign: _textAlign(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parsedBlocks.map((block) {
        return _buildBlock(block, theme);
      }).toList(),
    );
  }

  Widget _buildBlock(ContentBlock block, ThemePreference theme) {
    final style = _blockStyle(block.type, theme);
    final padding = _blockPadding(block.type);
    final align = block.type == ContentBlockType.divider
        ? TextAlign.center
        : block.type == ContentBlockType.congregationResponse ||
                block.type == ContentBlockType.response
            ? TextAlign.start
            : _textAlign();

    // Special rendering for certain types
    if (block.type == ContentBlockType.divider) {
      return Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(child: Divider(color: theme.dividerColor, thickness: 0.5)),
          ],
        ),
      );
    }

    if (block.type == ContentBlockType.rubric) {
      return Padding(
        padding: padding,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor, width: 0.5),
          ),
          child: Text(
            block.text,
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (block.type == ContentBlockType.priestText) {
      return Padding(
        padding: padding,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.15), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priest',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(block.text, style: style, textAlign: align),
            ],
          ),
        ),
      );
    }

    if (block.type == ContentBlockType.congregationResponse ||
        block.type == ContentBlockType.response) {
      return Padding(
        padding: padding,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryTextColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(block.text, style: style, textAlign: align),
            ],
          ),
        ),
      );
    }

    if (block.type == ContentBlockType.bibleQuote) {
      return Padding(
        padding: padding,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.4),
                width: 3,
              ),
            ),
          ),
          child: Text(block.text, style: style, textAlign: align),
        ),
      );
    }

    if (block.type == ContentBlockType.instruction) {
      return Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.accent.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Expanded(child: Text(block.text, style: style, textAlign: align)),
          ],
        ),
      );
    }

    if (block.type == ContentBlockType.note) {
      return Padding(
        padding: padding,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✝ ', style: TextStyle(color: AppColors.accent, fontSize: 16 * _fontScale)),
              Expanded(child: Text(block.text, style: style, textAlign: align)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Text(block.text, style: style, textAlign: align),
    );
  }

  Widget _buildHymnContent(ThemePreference theme) {
    if (_hymn == null) return const SizedBox.shrink();
    final lines = _hymn!.text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          return SizedBox(height: _paragraphSpacing);
        }
        if (trimmed == trimmed.toUpperCase() && trimmed.length > 3) {
          return Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              trimmed,
              style: _blockStyle(ContentBlockType.sectionHeading, theme),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            trimmed,
            style: _blockStyle(ContentBlockType.hymn, theme),
            textAlign: _textAlign(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(ThemePreference theme) {
    final section = _content != null
        ? _repo.getSectionById(_content!.section)
        : null;

    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 24),
        Icon(Icons.check_circle_outline, size: 32, color: AppColors.accent.withValues(alpha: 0.4)),
        const SizedBox(height: 8),
        Text(
          'End of $_title',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (section != null && _content != null) ...[
          const Text('Continue Reading',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent)),
          const SizedBox(height: 8),
          ...() {
            final currentIdx = section.items.indexOf(_content!.id);
            if (currentIdx >= 0 && currentIdx < section.items.length - 1) {
              final nextId = section.items[currentIdx + 1];
              final nextItem = _repo.getContentById(nextId);
              if (nextItem != null) {
                return [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderScreen(contentId: nextId),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nextItem.title,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: theme.textColor)),
                                Text('p. ${nextItem.pageNumber}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: theme.secondaryTextColor)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14, color: theme.secondaryTextColor),
                        ],
                      ),
                    ),
                  ),
                ];
              }
            }
            return <Widget>[];
          }(),
          // Related items hint
          if (_content?.relatedItems != null && _content!.relatedItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Related',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent)),
                  const SizedBox(height: 8),
                  ..._content!.relatedItems.take(3).map((id) {
                    final item = _repo.getContentById(id);
                    if (item == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReaderScreen(contentId: id),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward, size: 12,
                                color: AppColors.accent.withValues(alpha: 0.6)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(item.title,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: theme.textColor)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildFloatingToolbar(ThemePreference theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toolbarButton(Icons.bookmark_outline, _isBookmarked ? AppColors.accent : null, _toggleBookmark),
          _toolbarButton(Icons.auto_stories, null, _openOutline),
          _toolbarButton(Icons.search, null, null),
          _toolbarButton(Icons.text_fields, null, _openSettings),
          _toolbarButton(Icons.share_outlined, null, _shareContent),
          _toolbarButton(Icons.edit_outlined, null, _openReflection),
          if (_isBookmarked || _sections.isNotEmpty)
            _toolbarButton(
                Icons.details_outlined, null, _enterSacredMode),
        ],
      ),
    );
  }

  Widget _toolbarButton(IconData icon, Color? color, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
        splashRadius: 18,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  void _openOutline() {
    if (_sections.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildOutlineSheet(),
    );
  }

  Widget _buildOutlineSheet() {
    final theme = _themeNotifier.currentTheme;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Sections',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 12),
          ..._sections.asMap().entries.map((entry) {
            final isActive = entry.key == _visibleSectionIndex;
            return ListTile(
              leading: Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              title: Text(entry.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  )),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(entry.key);
              },
            );
          }),
        ],
      ),
    );
  }

  // -- Helpers --
  TextStyle _blockStyle(ContentBlockType type, ThemePreference theme) {
    final base = ReaderTypography.styleFor(type, theme, _fontScale, _fontFamily);
    return base.copyWith(height: _lineHeight);
  }

  EdgeInsets _blockPadding(ContentBlockType type) {
    final semantic = ReaderTypography.paddingFor(type);
    final spacing = type == ContentBlockType.sectionHeading ||
            type == ContentBlockType.subsectionHeading
        ? semantic
        : EdgeInsets.only(bottom: _paragraphSpacing);
    return spacing;
  }

  EdgeInsets _marginPadding() {
    switch (_margin) {
      case 'narrow':
        return const EdgeInsets.symmetric(horizontal: 16);
      case 'wide':
        return const EdgeInsets.symmetric(horizontal: 32);
      default:
        return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  TextAlign _textAlign() {
    switch (_alignment) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      default:
        return TextAlign.justify;
    }
  }

  CrossAxisAlignment _alignStart() {
    return _alignment == 'center' ? CrossAxisAlignment.center : CrossAxisAlignment.start;
  }

  String _getPageRange() {
    if (_content == null) return '';
    final section = _repo.getSectionById(_content!.section);
    if (section != null && section.pageStart != section.pageEnd) {
      return '${section.pageStart}–${section.pageEnd}';
    }
    return '${_content!.pageNumber}';
  }
}
