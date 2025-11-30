class Skill {
  final int? id;
  final int profileId;
  final String name;
  final String level;

  const Skill({
    this.id,
    required this.profileId,
    required this.name,
    required this.level,
  });

  Skill copyWith({
    int? id,
    int? profileId,
    String? name,
    String? level,
  }) {
    return Skill(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'name': name,
      'level': level,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      name: map['name'] as String,
      level: map['level'] as String,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Skill.fromJson(Map<String, dynamic> json) => Skill.fromMap(json);
}
