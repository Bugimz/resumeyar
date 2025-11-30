import 'package:get/get.dart';

enum ResumeSection {
  profile,
  workExperience,
  education,
  skills,
  projects,
  certifications,
  languages,
  interests,
}

extension ResumeSectionX on ResumeSection {
  String get translationKey {
    switch (this) {
      case ResumeSection.profile:
        return 'profile';
      case ResumeSection.workExperience:
        return 'work_experience';
      case ResumeSection.education:
        return 'education';
      case ResumeSection.skills:
        return 'skills';
      case ResumeSection.projects:
        return 'projects';
      case ResumeSection.certifications:
        return 'certifications';
      case ResumeSection.languages:
        return 'languages';
      case ResumeSection.interests:
        return 'interests';
    }
  }

  String get localizedLabel => translationKey.tr;
}
