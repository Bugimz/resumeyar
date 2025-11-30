enum SkillCategory { language, framework, tool }

enum SkillProficiency { beginner, intermediate, expert }

SkillCategory skillCategoryFromString(String? value) {
  return SkillCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => SkillCategory.language,
  );
}

SkillProficiency? skillProficiencyFromString(String? value) {
  if (value == null) {
    return null;
  }

  return SkillProficiency.values.firstWhereOrNull(
    (proficiency) => proficiency.name.toLowerCase() == value.toLowerCase(),
  );
}

extension on Iterable<SkillProficiency> {
  SkillProficiency? firstWhereOrNull(bool Function(SkillProficiency) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class Skill {
  final int? id;
  final int profileId;
  final String name;
  final SkillCategory category;
  final int? levelValue;
  final SkillProficiency? proficiency;
  final int sortOrder;

  const Skill({
    this.id,
    required this.profileId,
    required this.name,
    required this.category,
    this.levelValue,
    this.proficiency,
    this.sortOrder = 0,
  });

  /// ایجاد نمونه جدید با شناسه پایگاه‌داده بدون اتکا به copyWith
  Skill withDatabaseId(int newId) => Skill(
        id: newId,
        profileId: profileId,
        name: name,
        level: level,
      );

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'profileId': profileId,
      'name': name,
      'category': category.name,
      'levelValue': levelValue,
      'proficiency': proficiency?.name,
      'sortOrder': sortOrder,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    SkillProficiency? mappedProficiency =
        skillProficiencyFromString(map['proficiency'] as String?);
    int? mappedLevel = map['levelValue'] as int?;

    final legacyLevel = map['level'] as String?;
    if (legacyLevel != null && mappedLevel == null && mappedProficiency == null) {
      final parsed = int.tryParse(legacyLevel);
      if (parsed != null) {
        mappedLevel = parsed.clamp(1, 5);
      } else {
        mappedProficiency = skillProficiencyFromString(legacyLevel);
      }
    }

    return Skill(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      name: map['name'] as String,
      category: skillCategoryFromString(map['category'] as String?),
      levelValue: mappedLevel,
      proficiency: mappedProficiency,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Skill.fromJson(Map<String, dynamic> json) => Skill.fromMap(json);
}
