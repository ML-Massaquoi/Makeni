class BookSection {
  final String id;
  final String title;
  final List<String> items;
  final int pageStart;
  final int pageEnd;

  const BookSection({
    required this.id,
    required this.title,
    required this.items,
    required this.pageStart,
    required this.pageEnd,
  });

  factory BookSection.fromJson(Map<String, dynamic> json) {
    return BookSection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => i as String)
              .toList() ??
          [],
      pageStart: json['page_start'] as int? ?? 0,
      pageEnd: json['page_end'] as int? ?? 0,
    );
  }
}
