class Education {
  final int? id;
  final int profileId;
  final String school;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;
  final String description;

  const Education({
    this.id,
    required this.profileId,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

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
    );
  }
}
