class Skill {
  final int? id;
  final int profileId;
  final String name;
  final String level;
  final String category;
  final int sortOrder;

  const Skill({
    this.id,
    required this.profileId,
    required this.name,
    required this.level,
    required this.category,
    this.sortOrder = 0,
  });

  /// ایجاد نمونه جدید با شناسه پایگاه‌داده بدون اتکا به copyWith
  Skill withDatabaseId(int newId) => Skill(
        id: newId,
        profileId: profileId,
        name: name,
        level: level,
        category: category,
        sortOrder: sortOrder,
      );

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'profileId': profileId,
      'name': name,
      'level': level,
      'category': category,
      'sortOrder': sortOrder,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      name: map['name'] as String,
      level: map['level'] as String,
      category: (map['category'] as String?) ?? 'General',
      sortOrder: (map['sortOrder'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Skill.fromJson(Map<String, dynamic> json) => Skill.fromMap(json);
}
