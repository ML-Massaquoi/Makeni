import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference { light, dark, sepia, amoled }

class LocalStorage {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // -- Theme --
  ThemePreference getTheme() {
    final value = _prefs?.getString('theme') ?? 'light';
    return ThemePreference.values.firstWhere(
      (t) => t.name == value,
      orElse: () => ThemePreference.light,
    );
  }

  Future<void> setTheme(ThemePreference theme) async {
    await _prefs?.setString('theme', theme.name);
  }

  // -- Font Size --
  double getFontScale() => _prefs?.getDouble('font_scale') ?? 1.0;

  Future<void> setFontScale(double scale) async {
    await _prefs?.setDouble('font_scale', scale);
  }

  // -- Reading Mode --
  bool getUseSystemFont() => _prefs?.getBool('use_system_font') ?? true;

  Future<void> setUseSystemFont(bool value) async {
    await _prefs?.setBool('use_system_font', value);
  }

  // -- Last Read --
  String? getLastReadContentId() => _prefs?.getString('last_read_id');

  Future<void> setLastReadContentId(String id) async {
    await _prefs?.setString('last_read_id', id);
  }

  int getLastReadPage() => _prefs?.getInt('last_read_page') ?? 0;

  Future<void> setLastReadPage(int page) async {
    await _prefs?.setInt('last_read_page', page);
  }

  // -- Bookmarks --
  List<String> getBookmarks() =>
      _prefs?.getStringList('bookmarks') ?? [];

  Future<void> addBookmark(String contentId) async {
    final bookmarks = getBookmarks();
    if (!bookmarks.contains(contentId)) {
      bookmarks.add(contentId);
      await _prefs?.setStringList('bookmarks', bookmarks);
    }
  }

  Future<void> removeBookmark(String contentId) async {
    final bookmarks = getBookmarks();
    bookmarks.remove(contentId);
    await _prefs?.setStringList('bookmarks', bookmarks);
  }

  bool isBookmarked(String contentId) =>
      getBookmarks().contains(contentId);

  // -- Reading History --
  List<String> getReadingHistory() =>
      _prefs?.getStringList('reading_history') ?? [];

  Future<void> addToHistory(String contentId) async {
    final history = getReadingHistory();
    history.remove(contentId);
    history.insert(0, contentId);
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    await _prefs?.setStringList('reading_history', history);
  }

  // -- Reminders --
  List<String> getReminderTimes() =>
      _prefs?.getStringList('reminder_times') ?? [];

  Future<void> setReminderTimes(List<String> times) async {
    await _prefs?.setStringList('reminder_times', times);
  }

  bool getReminderEnabled() => _prefs?.getBool('reminder_enabled') ?? false;

  Future<void> setReminderEnabled(bool value) async {
    await _prefs?.setBool('reminder_enabled', value);
  }

  // -- Reader Settings --
  double getReaderFontScale() => _prefs?.getDouble('reader_font_scale') ?? 1.0;

  Future<void> setReaderFontScale(double value) async {
    await _prefs?.setDouble('reader_font_scale', value);
  }

  double getReaderLineHeight() => _prefs?.getDouble('reader_line_height') ?? 1.7;

  Future<void> setReaderLineHeight(double value) async {
    await _prefs?.setDouble('reader_line_height', value);
  }

  double getReaderParagraphSpacing() => _prefs?.getDouble('reader_paragraph_spacing') ?? 16.0;

  Future<void> setReaderParagraphSpacing(double value) async {
    await _prefs?.setDouble('reader_paragraph_spacing', value);
  }

  String getReaderFontFamily() => _prefs?.getString('reader_font_family') ?? 'Georgia';

  Future<void> setReaderFontFamily(String value) async {
    await _prefs?.setString('reader_font_family', value);
  }

  String getReaderAlignment() => _prefs?.getString('reader_alignment') ?? 'justify';

  Future<void> setReaderAlignment(String value) async {
    await _prefs?.setString('reader_alignment', value);
  }

  String getReaderMargin() => _prefs?.getString('reader_margin') ?? 'normal';

  Future<void> setReaderMargin(String value) async {
    await _prefs?.setString('reader_margin', value);
  }

  // -- Reflections --
  String? getReflection(String contentId) =>
      _prefs?.getString('reflection_$contentId');

  Future<void> setReflection(String contentId, String text) async {
    await _prefs?.setString('reflection_$contentId', text);
  }

  List<String> getReflectionIds() =>
      _prefs?.getStringList('reflection_ids') ?? [];

  Future<void> _addReflectionId(String contentId) async {
    final ids = getReflectionIds();
    if (!ids.contains(contentId)) {
      ids.add(contentId);
      await _prefs?.setStringList('reflection_ids', ids);
    }
  }

  Future<void> saveReflection(String contentId, String text) async {
    await setReflection(contentId, text);
    if (text.isNotEmpty) {
      await _addReflectionId(contentId);
    }
  }

  // -- Onboarding --
  bool isOnboardingComplete() => _prefs?.getBool('onboarding_complete') ?? false;

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool('onboarding_complete', value);
  }

  // -- Clear All --
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
