class AppConfig {
  static const String appName = 'Makeni Prayer and Hymn Book';
  static const String appSubtitle = 'Catholic Companion';
  static const String appVersion = '1.0.0';
  static const String bookId = 'makeni_prayer_book';
  static const String bookTitle = 'Prayer and Hymn Book';
  static const String bookSubtitle = 'Diocese of Makeni, Sierra Leone';
  static const String defaultLanguage = 'en';
  static const int totalPages = 224;
  static const int hymnStartPage = 120;
  static const int hymnEndPage = 198;
  static const int hymnIndexStartPage = 221;
  static const int hymnIndexEndPage = 224;
  static const int massStartPage = 21;
  static const int stationsStartPage = 82;
  static const int stationsEndPage = 111;
  static const int rosaryStartPage = 76;
  static const int rosaryEndPage = 81;

  static const String assetBookJson = 'assets/data/makeni_prayer_book.json';
  static const String assetSearchIndexJson = 'assets/data/search_index.json';
  static const String assetHymnsJson = 'assets/data/hymns.json';
  static const String assetContentItemsJson = 'assets/data/content_items.json';
  static const String assetSectionsJson = 'assets/data/sections.json';
  static const String assetRelationshipsJson = 'assets/data/relationships.json';
  static const String assetSqliteDb = 'assets/data/makeni_prayer_book.db';

  static const bool debugMode = bool.fromEnvironment('DEBUG', defaultValue: false);
}