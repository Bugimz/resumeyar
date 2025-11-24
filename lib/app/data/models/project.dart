class Project {
  final int? id;
  final int profileId;
  final String title;
  final String description;
  final String link;

  const Project({
    this.id,
    required this.profileId,
    required this.title,
    required this.description,
    required this.link,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'title': title,
      'description': description,
      'link': link,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      link: map['link'] as String,
    );
  }
}
