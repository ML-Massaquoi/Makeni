class Hymn {
  final int hymnNumber;
  final String title;
  final String text;
  final int startPage;
  final int endPage;
  final List<String> keywords;

  const Hymn({
    required this.hymnNumber,
    required this.title,
    required this.text,
    required this.startPage,
    required this.endPage,
    required this.keywords,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      hymnNumber: json['hymn_number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      startPage: json['start_page'] as int? ?? 0,
      endPage: json['end_page'] as int? ?? 0,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => k as String)
              .toList() ??
          [],
    );
  }
}
