import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../storage/local_storage.dart';

enum ContentBlockType {
  title,
  sectionHeading,
  subsectionHeading,
  prayer,
  prayerBody,
  priestText,
  congregationResponse,
  rubric,
  instruction,
  bibleQuote,
  hymn,
  note,
  divider,
  verse,
  paragraph,
  response,
}

class ContentBlock {
  final ContentBlockType type;
  final String text;
  final int level;
  final String? label;

  const ContentBlock({
    required this.type,
    required this.text,
    this.level = 0,
    this.label,
  });
}

class ContentParser {
  static List<ContentBlock> parse(String rawText, {String? title}) {
    final blocks = <ContentBlock>[];
    if (rawText.isEmpty) return blocks;

    String text = rawText
        .replaceAll(RegExp(r'\r\n?'), '\n')
        .replaceAll(RegExp(r' +\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        // Fix encoding corruption: replace diamond/garbled characters with proper apostrophes
        .replaceAll(RegExp(r'[^\x00-\x7F\u00A0-\u024F\u2018-\u201F\u2013\u2014\u2026\u00B7\u2022]'), "'")
        // Normalize common garbled apostrophes
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201A', "'")
        .replaceAll('\u201B', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u201E', '"')
        .replaceAll('\u201F', '"')
        .replaceAll('\u2013', '–')
        .replaceAll('\u2014', '—')
        .replaceAll('\u2026', '…')
        .replaceAll('?', "'")
        .replaceAll('�', "'")
        .trim();

    final lines = text.split('\n');
    List<String> buffer = [];
    ContentBlockType? currentType;

    void flushBuffer() {
      if (buffer.isEmpty) return;
      final merged = buffer.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (merged.isEmpty) return;
      blocks.add(_createBlock(merged, currentType));
      buffer.clear();
      currentType = null;
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        flushBuffer();
        continue;
      }

      // Skip empty numbered lines like "1." "2." with no content
      if (RegExp(r'^\d+\.\s*$').hasMatch(line)) {
        flushBuffer();
        continue;
      }

      final detected = _detectType(line);

      if (detected == ContentBlockType.divider) {
        flushBuffer();
        blocks.add(const ContentBlock(type: ContentBlockType.divider, text: '—'));
        continue;
      }

      if (detected == ContentBlockType.sectionHeading ||
          detected == ContentBlockType.subsectionHeading) {
        flushBuffer();
        blocks.add(ContentBlock(type: detected, text: line, level: 1));
        continue;
      }

      if (detected == ContentBlockType.rubric) {
        flushBuffer();
        currentType = ContentBlockType.rubric;
        buffer.add(line);
        continue;
      }

      if (detected == ContentBlockType.priestText) {
        flushBuffer();
        currentType = ContentBlockType.priestText;
        buffer.add(line.replaceFirst(RegExp(r'^Celebrant:\s*', caseSensitive: false), '').trim());
        continue;
      }

      if (detected == ContentBlockType.congregationResponse) {
        flushBuffer();
        currentType = ContentBlockType.congregationResponse;
        buffer.add(line.replaceFirst(RegExp(r'^(Congregation|All):\s*', caseSensitive: false), '').trim());
        continue;
      }

      if (detected == ContentBlockType.response) {
        flushBuffer();
        currentType = ContentBlockType.response;
        buffer.add(line.replaceFirst(RegExp(r'^(R/|℟|People):\s*'), '').trim());
        continue;
      }

      if (detected == ContentBlockType.instruction) {
        flushBuffer();
        blocks.add(ContentBlock(type: ContentBlockType.instruction, text: line));
        continue;
      }

      if (detected == ContentBlockType.bibleQuote) {
        flushBuffer();
        currentType = ContentBlockType.bibleQuote;
        buffer.add(line);
        continue;
      }

      if (detected == ContentBlockType.note) {
        flushBuffer();
        blocks.add(ContentBlock(type: ContentBlockType.note, text: line));
        continue;
      }

      if (detected == ContentBlockType.prayer) {
        flushBuffer();
        currentType = ContentBlockType.prayer;
        buffer.add(line);
        continue;
      }

      if (currentType == ContentBlockType.prayer && _isPrayerContinuation(line)) {
        buffer.add(line);
        continue;
      }

      if (currentType == ContentBlockType.priestText) {
        buffer.add(line);
        continue;
      }

      if (currentType == ContentBlockType.congregationResponse) {
        buffer.add(line);
        continue;
      }

      if (currentType == ContentBlockType.rubric && (line.startsWith('(') || line.endsWith(')'))) {
        buffer.add(line);
        continue;
      }

      if (currentType == ContentBlockType.bibleQuote || currentType == ContentBlockType.verse) {
        buffer.add(line);
        continue;
      }

      flushBuffer();
      currentType = ContentBlockType.paragraph;
      buffer.add(line);
    }

    flushBuffer();
    return blocks;
  }

  static ContentBlockType _detectType(String line) {
    if (line.length <= 2 && (line.contains('—') || line.contains('~') || line.contains('*'))) {
      return ContentBlockType.divider;
    }

    if (line == line.toUpperCase() && line.length > 3 && line.length < 60 &&
        !line.contains('.') && !line.contains('?')) {
      return ContentBlockType.sectionHeading;
    }

    if (line.startsWith('(') && line.endsWith(')')) {
      return ContentBlockType.rubric;
    }
    if (line.startsWith('[') && line.endsWith(']')) {
      return ContentBlockType.rubric;
    }

    if (RegExp(r'^Celebrant:\s', caseSensitive: false).hasMatch(line)) {
      return ContentBlockType.priestText;
    }

    if (RegExp(r'^(Congregation|All):\s', caseSensitive: false).hasMatch(line)) {
      return ContentBlockType.congregationResponse;
    }

    if (RegExp(r'^(R/|℟|People):\s').hasMatch(line)) {
      return ContentBlockType.response;
    }

    if (RegExp(r'^(Reader|Lector|Deacon|Priest):\s', caseSensitive: false).hasMatch(line)) {
      return ContentBlockType.instruction;
    }

    if (RegExp(r'^(V/|℣):\s').hasMatch(line)) {
      return ContentBlockType.instruction;
    }

    if (line.endsWith('"') && line.startsWith('"')) {
      return ContentBlockType.bibleQuote;
    }

    if (RegExp(r'^Note[:\s]', caseSensitive: false).hasMatch(line)) {
      return ContentBlockType.note;
    }

    if (RegExp(r'^(Let us pray|O God,|Almighty|Lord,|Father,|We pray|Grant|Merciful)',
        caseSensitive: false).hasMatch(line)) {
      return ContentBlockType.prayer;
    }

    if (line.endsWith('Amen.') || line.endsWith('Amen!')) {
      return ContentBlockType.prayer;
    }

    return ContentBlockType.paragraph;
  }

  static bool _isPrayerContinuation(String line) {
    return line.startsWith(' ') ||
        line.startsWith('that') ||
        line.startsWith('through') ||
        line.startsWith('who') ||
        line.startsWith('we') ||
        line.startsWith('may') ||
        line.endsWith(',');
  }

  static ContentBlock _createBlock(String text, ContentBlockType? type) {
    return ContentBlock(type: type ?? ContentBlockType.paragraph, text: text);
  }
}

class ReaderTypography {
  // Design system fonts
  static const String headingFont = 'Playfair Display';
  static const String bodyFont = 'Lora';
  static const String uiFont = 'Poppins';

  static TextStyle styleFor(
    ContentBlockType type,
    ThemePreference theme,
    double scale,
    String fontFamily,
  ) {
    final baseColor = _textColor(theme);
    final secondaryColor = _secondaryColor(theme);
    final accentColor = _accentColor(theme);

    TextStyle base({
      double size = 18,
      FontWeight weight = FontWeight.normal,
      double height = 1.7,
      Color? color,
      String? font,
      double spacing = 0.2,
      FontStyle style = FontStyle.normal,
    }) {
      return TextStyle(
        fontSize: size * scale,
        fontWeight: weight,
        height: height,
        color: color ?? baseColor,
        fontFamily: font ?? bodyFont,
        letterSpacing: spacing,
        fontStyle: style,
      );
    }

    switch (type) {
      case ContentBlockType.title:
        return base(size: 26, weight: FontWeight.w700, height: 1.3, spacing: -0.3, font: headingFont);
      case ContentBlockType.sectionHeading:
        return base(size: 20, weight: FontWeight.w700, height: 1.4, color: accentColor, spacing: 0.8, font: headingFont);
      case ContentBlockType.subsectionHeading:
        return base(size: 17, weight: FontWeight.w600, height: 1.4, color: accentColor, spacing: 0.5, font: headingFont);
      case ContentBlockType.prayer:
        return base(size: 18, weight: FontWeight.normal, height: 1.85, spacing: 0.3, font: bodyFont);
      case ContentBlockType.prayerBody:
        return base(size: 18, weight: FontWeight.normal, height: 1.85, spacing: 0.3, font: bodyFont);
      case ContentBlockType.priestText:
        return base(size: 17, weight: FontWeight.w500, height: 1.7, color: accentColor, spacing: 0.3, font: bodyFont);
      case ContentBlockType.congregationResponse:
        return base(size: 17, weight: FontWeight.w600, height: 1.7, spacing: 0.3, style: FontStyle.italic, font: bodyFont);
      case ContentBlockType.rubric:
        return base(size: 14, weight: FontWeight.normal, height: 1.5, color: secondaryColor, style: FontStyle.italic, font: uiFont);
      case ContentBlockType.instruction:
        return base(size: 14, weight: FontWeight.w500, height: 1.6, color: accentColor, spacing: 0.5, font: uiFont);
      case ContentBlockType.bibleQuote:
        return base(size: 17, weight: FontWeight.normal, height: 1.8, color: baseColor, spacing: 0.3, style: FontStyle.italic, font: bodyFont);
      case ContentBlockType.hymn:
        return base(size: 17, weight: FontWeight.normal, height: 1.7, spacing: 0.2, font: bodyFont);
      case ContentBlockType.note:
        return base(size: 14, weight: FontWeight.normal, height: 1.5, color: secondaryColor, font: uiFont);
      case ContentBlockType.divider:
        return base(size: 20, weight: FontWeight.normal, height: 1, color: secondaryColor);
      case ContentBlockType.verse:
        return base(size: 17, weight: FontWeight.normal, height: 1.7, spacing: 0.2, font: bodyFont);
      case ContentBlockType.paragraph:
        return base(size: 18, weight: FontWeight.normal, height: 1.8, spacing: 0.2, font: bodyFont);
      case ContentBlockType.response:
        return base(size: 17, weight: FontWeight.w600, height: 1.7, spacing: 0.3, style: FontStyle.italic, font: bodyFont);
    }
  }

  static EdgeInsets paddingFor(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.sectionHeading:
        return const EdgeInsets.only(top: 40, bottom: 16);
      case ContentBlockType.subsectionHeading:
        return const EdgeInsets.only(top: 28, bottom: 12);
      case ContentBlockType.divider:
        return const EdgeInsets.symmetric(vertical: 20);
      case ContentBlockType.priestText:
        return const EdgeInsets.only(left: 16, top: 12, bottom: 12);
      case ContentBlockType.congregationResponse:
        return const EdgeInsets.only(left: 16, top: 12, bottom: 12);
      case ContentBlockType.rubric:
        return const EdgeInsets.symmetric(vertical: 6);
      case ContentBlockType.bibleQuote:
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
      case ContentBlockType.prayer:
        return const EdgeInsets.only(bottom: 20);
      default:
        return const EdgeInsets.only(bottom: 16);
    }
  }

  static Color _textColor(ThemePreference theme) {
    switch (theme) {
      case ThemePreference.light:
        return AppColors.textPrimary;
      case ThemePreference.dark:
        return AppColors.darkTextPrimary;
      case ThemePreference.sepia:
        return AppColors.sepiaText;
      case ThemePreference.amoled:
        return Colors.white;
    }
  }

  static Color _secondaryColor(ThemePreference theme) {
    switch (theme) {
      case ThemePreference.light:
        return AppColors.textSecondary;
      case ThemePreference.dark:
        return AppColors.darkTextSecondary;
      case ThemePreference.sepia:
        return AppColors.sepiaText.withValues(alpha: 0.7);
      case ThemePreference.amoled:
        return Colors.grey;
    }
  }

  static Color _accentColor(ThemePreference theme) {
    switch (theme) {
      case ThemePreference.amoled:
        return AppColors.accentLight;
      default:
        return AppColors.accent;
    }
  }
}

extension ThemePreferenceHelper on ThemePreference {
  bool get isLight => this == ThemePreference.light || this == ThemePreference.sepia;
  bool get isDark => this == ThemePreference.dark || this == ThemePreference.amoled;

  Color get backgroundColor {
    switch (this) {
      case ThemePreference.light:
        return AppColors.background;
      case ThemePreference.dark:
        return AppColors.darkBackground;
      case ThemePreference.sepia:
        return AppColors.sepiaBackground;
      case ThemePreference.amoled:
        return AppColors.amoledBackground;
    }
  }

  Color get surfaceColor {
    switch (this) {
      case ThemePreference.light:
        return AppColors.surface;
      case ThemePreference.dark:
        return AppColors.darkSurface;
      case ThemePreference.sepia:
        return const Color(0xFFF4ECD8);
      case ThemePreference.amoled:
        return AppColors.amoledSurface;
    }
  }

  Color get textColor {
    switch (this) {
      case ThemePreference.light:
        return AppColors.textPrimary;
      case ThemePreference.dark:
        return AppColors.darkTextPrimary;
      case ThemePreference.sepia:
        return AppColors.sepiaText;
      case ThemePreference.amoled:
        return Colors.white;
    }
  }

  Color get secondaryTextColor {
    switch (this) {
      case ThemePreference.light:
        return AppColors.textSecondary;
      case ThemePreference.dark:
        return AppColors.darkTextSecondary;
      case ThemePreference.sepia:
        return AppColors.sepiaText.withValues(alpha: 0.7);
      case ThemePreference.amoled:
        return Colors.grey;
    }
  }

  Color get dividerColor {
    switch (this) {
      case ThemePreference.light:
        return AppColors.divider;
      case ThemePreference.dark:
        return AppColors.darkDivider;
      case ThemePreference.sepia:
        return AppColors.divider;
      case ThemePreference.amoled:
        return const Color(0xFF1A1A1A);
    }
  }
}
