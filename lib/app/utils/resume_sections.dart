import 'package:get/get.dart';

enum ResumeSection {
  profile,
  workExperience,
  education,
  skills,
  projects,
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
    }
  }

  String get localizedLabel => translationKey.tr;
}
