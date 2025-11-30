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

  Skill copyWith({
    int? id,
    int? profileId,
    String? name,
    SkillCategory? category,
    int? levelValue,
    SkillProficiency? proficiency,
    int? sortOrder,
  }) {
    return Skill(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      category: category ?? this.category,
      levelValue: levelValue ?? this.levelValue,
      proficiency: proficiency ?? this.proficiency,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  String get displayLevel {
    if (levelValue != null) {
      return levelValue!.clamp(1, 5).toString();
    }
    if (proficiency != null) {
      switch (proficiency!) {
        case SkillProficiency.beginner:
          return 'Beginner';
        case SkillProficiency.intermediate:
          return 'Intermediate';
        case SkillProficiency.expert:
          return 'Expert';
      }
    }
    return '';
  }

  double? get levelProgress {
    if (levelValue != null) {
      return levelValue!.clamp(1, 5) / 5.0;
    }
    switch (proficiency) {
      case SkillProficiency.beginner:
        return 0.33;
      case SkillProficiency.intermediate:
        return 0.66;
      case SkillProficiency.expert:
        return 1.0;
      case null:
        return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
}
