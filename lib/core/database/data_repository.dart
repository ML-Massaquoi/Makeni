import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import 'models/models.dart';

class DataRepository {
  final Map<String, ContentItem> _contentItems = {};
  final Map<String, BookSection> _sections = {};
  final Map<int, Hymn> _hymns = {};
  final List<ContentRelationship> _relationships = [];
  final Map<String, SearchEntry> _searchEntries = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    final errors = <String>[];

    await Future.wait([
      _loadContentItems().catchError((e) => errors.add('content_items: $e')),
      _loadSections().catchError((e) => errors.add('sections: $e')),
      _loadHymns().catchError((e) => errors.add('hymns: $e')),
      _loadRelationships().catchError((e) => errors.add('relationships: $e')),
      _loadSearchIndex().catchError((e) => errors.add('search_index: $e')),
    ]);

    if (errors.isNotEmpty) {
      throw Exception('DataRepository initialization failed: ${errors.join('; ')}');
    }

    _initialized = true;
  }

  Future<void> _loadContentItems() async {
    final jsonString =
        await rootBundle.loadString(AppConfig.assetContentItemsJson);
    final list = json.decode(jsonString) as List<dynamic>;
    for (final item in list) {
      final ci = ContentItem.fromJson(item as Map<String, dynamic>);
      _contentItems[ci.id] = ci;
    }
  }

  Future<void> _loadSections() async {
    final jsonString =
        await rootBundle.loadString(AppConfig.assetSectionsJson);
    final list = json.decode(jsonString) as List<dynamic>;
    for (final item in list) {
      final s = BookSection.fromJson(item as Map<String, dynamic>);
      _sections[s.id] = s;
    }
  }

  Future<void> _loadHymns() async {
    final jsonString =
        await rootBundle.loadString(AppConfig.assetHymnsJson);
    final list = json.decode(jsonString) as List<dynamic>;
    for (final item in list) {
      final h = Hymn.fromJson(item as Map<String, dynamic>);
      _hymns[h.hymnNumber] = h;
    }
  }

  Future<void> _loadRelationships() async {
    final jsonString =
        await rootBundle.loadString(AppConfig.assetRelationshipsJson);
    final list = json.decode(jsonString) as List<dynamic>;
    for (final item in list) {
      _relationships
          .add(ContentRelationship.fromJson(item as Map<String, dynamic>));
    }
  }

  Future<void> _loadSearchIndex() async {
    final jsonString =
        await rootBundle.loadString(AppConfig.assetSearchIndexJson);
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final entries = data['entries'] as List<dynamic>;
    for (final entry in entries) {
      final se = SearchEntry.fromJson(entry as Map<String, dynamic>);
      _searchEntries[se.contentId] = se;
    }
  }

  ContentItem? getContentById(String id) => _contentItems[id];

  ContentItem? getContentByPage(int pageNumber) =>
      _contentItems.values.where((c) => c.pageNumber == pageNumber).firstOrNull;

  List<ContentItem> getAllContent() => _contentItems.values.toList();

  List<ContentItem> getContentBySection(String sectionId) =>
      _contentItems.values.where((c) => c.section == sectionId).toList();

  List<ContentItem> getContentByType(String type) =>
      _contentItems.values.where((c) => c.type == type).toList();

  BookSection? getSectionById(String id) => _sections[id];

  List<BookSection> getAllSections() => _sections.values.toList();

  Hymn? getHymnByNumber(int number) => _hymns[number];

  List<Hymn> getAllHymns() => _hymns.values.toList();

  List<ContentRelationship> getRelationships() => _relationships;

  List<ContentRelationship> getRelationshipsFor(String contentId) =>
      _relationships
          .where(
              (r) => r.sourceId == contentId || r.targetId == contentId)
          .toList();

  List<ContentItem> getRelatedContent(String contentId) {
    final ids = <String>{};
    for (final rel in _relationships) {
      if (rel.sourceId == contentId) ids.add(rel.targetId);
      if (rel.targetId == contentId) ids.add(rel.sourceId);
    }
    return ids.map((id) => _contentItems[id]).whereType<ContentItem>().toList();
  }

  SearchEntry? getSearchEntry(String contentId) => _searchEntries[contentId];

  List<SearchEntry> getAllSearchEntries() => _searchEntries.values.toList();

  List<SearchEntry> search(String query) {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    return _searchEntries.values.where((entry) {
      if (entry.title.toLowerCase().contains(lower)) return true;
      if (entry.keywords.any((k) => k.toLowerCase().contains(lower))) {
        return true;
      }
      if (entry.tokens.any((t) => t.toLowerCase().contains(lower))) {
        return true;
      }
      if (entry.contentType.toLowerCase().contains(lower)) return true;
      return false;
    }).toList()
      ..sort((a, b) => b.searchWeight.compareTo(a.searchWeight));
  }
}
