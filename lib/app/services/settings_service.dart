import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/resume_sections.dart';

enum PdfPageSize { a4, letter }

enum PdfThemeMode { light, dark }

class SettingsService {
  static const String _sectionOrderKey = 'resume_section_order';
  static const String _sectionVisibilityKey = 'resume_section_visibility';
  static const String _pageFormatKey = 'pdf_page_format';
  static const String _pdfThemeKey = 'pdf_theme_mode';
  static const String _showGpaKey = 'pdf_show_gpa';

  Future<List<ResumeSection>> loadResumeSectionOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final storedOrder = prefs.getStringList(_sectionOrderKey);

    if (storedOrder == null) {
      return List.of(ResumeSection.values);
    }

    final sections = storedOrder
        .map(_sectionFromName)
        .whereType<ResumeSection>()
        .toList();

    for (final section in ResumeSection.values) {
      if (!sections.contains(section)) {
        sections.add(section);
      }
    }

    return sections;
  }

  Future<void> saveResumeSectionOrder(List<ResumeSection> order) async {
    final prefs = await SharedPreferences.getInstance();
    final values = order.map((section) => section.name).toList();
    await prefs.setStringList(_sectionOrderKey, values);
  }

  Future<Set<ResumeSection>> loadHiddenSections() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_sectionVisibilityKey);

    if (stored == null) {
      return <ResumeSection>{};
    }

    return stored
        .map(_sectionFromName)
        .whereType<ResumeSection>()
        .toSet();
  }

  Future<void> saveHiddenSections(Set<ResumeSection> hidden) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _sectionVisibilityKey,
      hidden.map((section) => section.name).toList(),
    );
  }

  Future<PdfPageFormat> loadPageFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pageFormatKey);

    switch (stored) {
      case 'letter':
        return PdfPageFormat.letter;
      case 'a4':
      default:
        return PdfPageFormat.a4;
    }
  }

  Future<void> savePageFormat(PdfPageSize size) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (size) {
      PdfPageSize.a4 => 'a4',
      PdfPageSize.letter => 'letter',
    };

    await prefs.setString(_pageFormatKey, value);
  }

  Future<PdfThemeMode> loadPdfTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pdfThemeKey);

    switch (stored) {
      case 'dark':
        return PdfThemeMode.dark;
      case 'light':
      default:
        return PdfThemeMode.light;
    }
  }

  Future<void> savePdfTheme(PdfThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      PdfThemeMode.light => 'light',
      PdfThemeMode.dark => 'dark',
    };

    await prefs.setString(_pdfThemeKey, value);
  }

  Future<bool> loadGpaVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showGpaKey) ?? true;
  }

  Future<void> saveGpaVisibility(bool visible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showGpaKey, visible);
  }

  ResumeSection? _sectionFromName(String name) {
    for (final section in ResumeSection.values) {
      if (section.name == name) {
        return section;
      }
    }
    return null;
  }
}
