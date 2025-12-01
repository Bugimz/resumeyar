class Interest {
  final int? id;
  final String name;
  final String description;

  const Interest({
    this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Interest.fromMap(Map<String, dynamic> map) {
    return Interest(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

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
