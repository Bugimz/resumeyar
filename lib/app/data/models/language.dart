class Language {
  final int? id;
  final String name;
  final String proficiency;

  const Language({
    this.id,
    required this.name,
    required this.proficiency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'proficiency': proficiency,
    };
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      proficiency: map['proficiency'] as String? ?? '',
    );
  }

  Language copyWith({
    int? id,
    String? name,
    String? proficiency,
  }) {
    return Language(
      id: id ?? this.id,
      name: name ?? this.name,
      proficiency: proficiency ?? this.proficiency,
    );
  }
}
