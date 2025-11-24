import 'package:shared_preferences/shared_preferences.dart';

import '../utils/resume_sections.dart';

class SettingsService {
  static const String _sectionOrderKey = 'resume_section_order';

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

  ResumeSection? _sectionFromName(String name) {
    for (final section in ResumeSection.values) {
      if (section.name == name) {
        return section;
      }
    }
    return null;
  }
}
