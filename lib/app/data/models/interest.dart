class Interest {
  final int? id;
  final String name;
  final String description;

  const Interest({
    this.id,
    required this.name,
    required this.description,
  });

  Interest copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Interest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
