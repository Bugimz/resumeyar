class ResumeProfile {
  final int? id;
  final String fullName;
  final String jobTitle;
  final String location;
  final String email;
  final String phone;
  final String summary;
  final String portfolioUrl;
  final String linkedInUrl;
  final String githubUrl;
  final String? imagePath;
  final String? signaturePath;

  const ResumeProfile({
    this.id,
    required this.fullName,
    this.jobTitle = '',
    this.location = '',
    required this.email,
    required this.phone,
    required this.summary,
    this.portfolioUrl = '',
    this.linkedInUrl = '',
    this.githubUrl = '',
    this.imagePath,
    this.signaturePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'location': location,
      'email': email,
      'phone': phone,
      'summary': summary,
      'portfolioUrl': portfolioUrl,
      'linkedInUrl': linkedInUrl,
      'githubUrl': githubUrl,
      'imagePath': imagePath,
      'signaturePath': signaturePath,
    };
  }

  factory ResumeProfile.fromMap(Map<String, dynamic> map) {
    return ResumeProfile(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      jobTitle: (map['jobTitle'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      email: map['email'] as String,
      phone: map['phone'] as String,
      summary: map['summary'] as String,
      portfolioUrl: (map['portfolioUrl'] as String?) ?? '',
      linkedInUrl: (map['linkedInUrl'] as String?) ?? '',
      githubUrl: (map['githubUrl'] as String?) ?? '',
      imagePath: map['imagePath'] as String?,
      signaturePath: map['signaturePath'] as String?,
    );
  }
}
