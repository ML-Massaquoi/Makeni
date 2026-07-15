class SearchEntry {
  final String id;
  final String contentId;
  final String title;
  final String text;
  final List<String> keywords;
  final int? hymnNumber;
  final int pageNumber;
  final String category;
  final String contentType;
  final double searchWeight;
  final List<String> tokens;
  final List<String> prefixTokens;

  const SearchEntry({
    required this.id,
    required this.contentId,
    required this.title,
    required this.text,
    required this.keywords,
    this.hymnNumber,
    required this.pageNumber,
    required this.category,
    required this.contentType,
    required this.searchWeight,
    required this.tokens,
    required this.prefixTokens,
  });

  factory SearchEntry.fromJson(Map<String, dynamic> json) {
    return SearchEntry(
      id: json['id'] as String? ?? '',
      contentId: json['content_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => k as String)
              .toList() ??
          [],
      hymnNumber: json['hymn_number'] as int?,
      pageNumber: json['page_number'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      contentType: json['content_type'] as String? ?? '',
      searchWeight: (json['search_weight'] as num?)?.toDouble() ?? 1.0,
      tokens: (json['tokens'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      prefixTokens: (json['prefix_tokens'] as List<dynamic>?)
              ?.map((p) => p as String)
              .toList() ??
          [],
    );
  }
}
