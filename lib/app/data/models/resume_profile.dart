class ResumeProfile {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String summary;

  const ResumeProfile({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.summary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'summary': summary,
    };
  }

  factory ResumeProfile.fromMap(Map<String, dynamic> map) {
    return ResumeProfile(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      summary: map['summary'] as String,
    );
  }
}
