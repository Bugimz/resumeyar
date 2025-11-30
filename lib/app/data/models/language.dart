class Language {
  final int? id;
  final String name;
  final String proficiency;

  const Language({
    this.id,
    required this.name,
    required this.proficiency,
  });

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
