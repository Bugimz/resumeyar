class WorkExperience {
  final int? id;
  final int profileId;
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String description;

  const WorkExperience({
    this.id,
    required this.profileId,
    required this.company,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.description,
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
    );
  }
}
