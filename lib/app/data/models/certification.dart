class Certification {
  final int? id;
  final String title;
  final String issuer;
  final String issueDate;
  final String credentialUrl;

  const Certification({
    this.id,
    required this.title,
    required this.issuer,
    required this.issueDate,
    required this.credentialUrl,
  });

  Certification copyWith({
    int? id,
    String? title,
    String? issuer,
    String? issueDate,
    String? credentialUrl,
  }) {
    return Certification(
      id: id ?? this.id,
      title: title ?? this.title,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      credentialUrl: credentialUrl ?? this.credentialUrl,
    );
  }
}
