class TextBlock {
  final String type;
  final String text;
  final int level;

  const TextBlock({
    required this.type,
    required this.text,
    this.level = 0,
  });

  factory TextBlock.fromJson(Map<String, dynamic> json) {
    return TextBlock(
      type: json['type'] as String? ?? 'paragraph',
      text: json['text'] as String? ?? '',
      level: json['level'] as int? ?? 0,
    );
  }
}

class ContentItem {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String category;
  final String section;
  final int pageNumber;
  final String text;
  final List<TextBlock> blocks;
  final List<String> keywords;
  final List<String> tags;
  final String language;
  final String version;
  final int sourcePage;
  final double searchWeight;
  final String liturgicalSeason;
  final double readingTimeMinutes;
  final List<String> relatedItems;
  final String parentId;

  const ContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.section,
    required this.pageNumber,
    required this.text,
    required this.blocks,
    required this.keywords,
    required this.tags,
    required this.language,
    required this.version,
    required this.sourcePage,
    required this.searchWeight,
    required this.liturgicalSeason,
    required this.readingTimeMinutes,
    required this.relatedItems,
    required this.parentId,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'prayer',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? '',
      section: json['section'] as String? ?? '',
      pageNumber: json['page_number'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((b) => TextBlock.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => k as String)
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      language: json['language'] as String? ?? 'en',
      version: json['version'] as String? ?? '1.0',
      sourcePage: json['source_page'] as int? ?? 0,
      searchWeight: (json['search_weight'] as num?)?.toDouble() ?? 1.0,
      liturgicalSeason: json['liturgical_season'] as String? ?? '',
      readingTimeMinutes:
          (json['reading_time_minutes'] as num?)?.toDouble() ?? 1.0,
      relatedItems: (json['related_items'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
      parentId: json['parent_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'section': section,
        'page_number': pageNumber,
        'text': text,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'keywords': keywords,
        'tags': tags,
        'language': language,
        'version': version,
        'source_page': sourcePage,
        'search_weight': searchWeight,
        'liturgical_season': liturgicalSeason,
        'reading_time_minutes': readingTimeMinutes,
        'related_items': relatedItems,
        'parent_id': parentId,
      };
}

extension TextBlockJson on TextBlock {
  Map<String, dynamic> toJson() => {
        'type': type,
        'text': text,
        'level': level,
      };
}
