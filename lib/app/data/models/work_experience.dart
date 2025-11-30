import 'dart:convert';

class WorkExperience {
  final int? id;
  final int profileId;
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String description;
  final List<String> achievements;
  final List<String> techTags;
  final String? metric;

  const WorkExperience({
    this.id,
    required this.profileId,
    required this.company,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.achievements,
    required this.techTags,
    this.metric,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'company': company,
      'position': position,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'achievements': achievements,
      'techTags': techTags,
      'metric': metric,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'profileId': profileId,
      'company': company,
      'position': position,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'achievements': jsonEncode(achievements),
      'techTags': jsonEncode(techTags),
      'metric': metric,
    };
  }

  factory WorkExperience.fromMap(Map<String, dynamic> map) {
    return WorkExperience(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      company: map['company'] as String,
      position: map['position'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      description: map['description'] as String,
      achievements: _decodeStringList(map['achievements']),
      techTags: _decodeStringList(map['techTags']),
      metric: map['metric'] as String?,
    );
  }

  static List<String> _decodeStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }

    if (value is String && value.isNotEmpty) {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    }

    return const [];
  }
}
