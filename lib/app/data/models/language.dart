class Language {
  Language({
    this.id,
    required this.profileId,
    required this.name,
    required this.level,
    this.sortOrder = 0,
  });

  final int? id;
  final int profileId;
  final String name;
  final String level;
  final int sortOrder;

  Language copyWith({
    int? id,
    int? profileId,
    String? name,
    String? level,
    int? sortOrder,
  }) {
    return Language(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      level: level ?? this.level,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'name': name,
      'level': level,
      'sortOrder': sortOrder,
    };
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      name: map['name'] as String,
      level: map['level'] as String,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }
}
