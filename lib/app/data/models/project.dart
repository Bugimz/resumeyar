import 'dart:convert';

class Project {
  final int? id;
  final int profileId;
  final String title;
  final String description;
  final String link;
  final String role;
  final List<String> responsibilities;
  final List<String> techTags;
  final String demoLink;
  final String githubLink;
  final String liveLink;
  final String thumbnailUrl;
  final bool isFeatured;

  const Project({
    this.id,
    required this.profileId,
    required this.title,
    required this.description,
    required this.link,
    this.role = '',
    this.responsibilities = const [],
    this.techTags = const [],
    this.demoLink = '',
    this.githubLink = '',
    this.liveLink = '',
    this.thumbnailUrl = '',
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'title': title,
      'description': description,
      'link': link,
      'role': role,
      'responsibilities': jsonEncode(responsibilities),
      'techTags': jsonEncode(techTags),
      'demoLink': demoLink,
      'githubLink': githubLink,
      'liveLink': liveLink,
      'thumbnailUrl': thumbnailUrl,
      'isFeatured': isFeatured ? 1 : 0,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      link: map['link'] as String,
      role: (map['role'] ?? '') as String,
      responsibilities: _decodeList(map['responsibilities']),
      techTags: _decodeList(map['techTags']),
      demoLink: (map['demoLink'] ?? '') as String,
      githubLink: (map['githubLink'] ?? '') as String,
      liveLink: (map['liveLink'] ?? '') as String,
      thumbnailUrl: (map['thumbnailUrl'] ?? '') as String,
      isFeatured: (map['isFeatured'] ?? 0) == 1,
    );
  }

  static List<String> _decodeList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      return List<String>.from(jsonDecode(value) as List).map((e) => e.toString()).toList();
    }
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}
