class Certification {
  Certification({
    this.id,
    required this.profileId,
    required this.name,
    required this.issuer,
    required this.issueDate,
    required this.credentialUrl,
    this.sortOrder = 0,
  });

  final int? id;
  final int profileId;
  final String name;
  final String issuer;
  final String issueDate;
  final String credentialUrl;
  final int sortOrder;

  Certification copyWith({
    int? id,
    int? profileId,
    String? name,
    String? issuer,
    String? issueDate,
    String? credentialUrl,
    int? sortOrder,
  }) {
    return Certification(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      credentialUrl: credentialUrl ?? this.credentialUrl,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'name': name,
      'issuer': issuer,
      'issueDate': issueDate,
      'credentialUrl': credentialUrl,
      'sortOrder': sortOrder,
    };
  }

  factory Certification.fromMap(Map<String, dynamic> map) {
    return Certification(
      id: map['id'] as int?,
      profileId: map['profileId'] as int,
      name: map['name'] as String,
      issuer: map['issuer'] as String,
      issueDate: map['issueDate'] as String,
      credentialUrl: map['credentialUrl'] as String,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }
}
