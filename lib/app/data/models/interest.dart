class Interest {
  Interest({
    this.id,
    required this.profileId,
    required this.title,
    this.details = '',
    this.sortOrder = 0,
  });

  final int? id;
  final int profileId;
  final String title;
  final String details;
  final int sortOrder;

  Interest copyWith({
    int? id,
    int? profileId,
    String? title,
    String? details,
    int? sortOrder,
  }) {
    return Interest(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      details: details ?? this.details,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'title': title,
      'details': details,
      'sortOrder': sortOrder,
    };
  }

  factory Interest.fromMap(Map<String, dynamic> map) {
    return Interest(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      title: map['title'] as String,
      details: map['details'] as String? ?? '',
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }
}
