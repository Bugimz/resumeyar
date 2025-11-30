import 'dart:convert';

class Education {
  final int? id;
  final int profileId;
  final String school;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;
  final String description;
  final double? gpa;
  final bool showGpa;
  final List<String> honors;
  final List<String> courses;
  final int sortOrder;

  const Education({
    this.id,
    required this.profileId,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.gpa,
    this.showGpa = false,
    this.honors = const [],
    this.courses = const [],
    this.sortOrder = 0,
  });

  Education copyWith({
    int? id,
    int? profileId,
    String? school,
    String? degree,
    String? fieldOfStudy,
    String? startDate,
    String? endDate,
    String? description,
    double? gpa,
    bool? showGpa,
    List<String>? honors,
    List<String>? courses,
    int? sortOrder,
  }) {
    return Education(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      school: school ?? this.school,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      gpa: gpa ?? this.gpa,
      showGpa: showGpa ?? this.showGpa,
      honors: honors ?? this.honors,
      courses: courses ?? this.courses,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'school': school,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'gpa': gpa,
      'showGpa': showGpa ? 1 : 0,
      'honors': jsonEncode(honors),
      'courses': jsonEncode(courses),
      'sortOrder': sortOrder,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      school: map['school'] as String,
      degree: map['degree'] as String,
      fieldOfStudy: map['fieldOfStudy'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      description: map['description'] as String,
      gpa: (map['gpa'] as num?)?.toDouble(),
      showGpa: (map['showGpa'] ?? 0) == 1,
      honors: _decodeStringList(map['honors']),
      courses: _decodeStringList(map['courses']),
      sortOrder: (map['sortOrder'] as int?) ?? 0,
    );
  }

  static List<String> _decodeStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }

    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.whereType<String>().toList();
        }
      } catch (_) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return const [];
  }
}
