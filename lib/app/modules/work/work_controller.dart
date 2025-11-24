import 'package:get/get.dart';

import '../../data/models/work_experience.dart';
import '../../data/repositories/work_experience_repository.dart';

class WorkController extends GetxController {
  WorkController({required this.repository});

  final WorkExperienceRepository repository;

  Future<List<WorkExperience>> load(int profileId) {
    return repository.getByProfile(profileId);
  }

  Future<int> save(WorkExperience experience) {
    return repository.create(experience);
  }

  Future<int> update(WorkExperience experience) {
    return repository.update(experience);
  }
}
