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
    SkillCategory? category,  // اصلاح برای دسته بندی
    int? levelValue,          // اصلاح برای سطح
    SkillProficiency? proficiency,  // اصلاح برای مهارت
    int? sortOrder,
  }) {
    return Skill(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      category: category ?? this.category, // اصلاح برای دسته بندی
      levelValue: levelValue ?? this.levelValue,  // اصلاح برای سطح
      proficiency: proficiency ?? this.proficiency, // اصلاح برای مهارت
      sortOrder: sortOrder ?? this.sortOrder,
    );
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

  Map<String, dynamic> toJson() => toMap();

  factory Skill.fromJson(Map<String, dynamic> json) => Skill.fromMap(json);
}
