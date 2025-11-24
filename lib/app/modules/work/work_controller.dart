import 'package:get/get.dart';

import '../../data/models/work_experience.dart';
import '../../data/repositories/work_experience_repository.dart';

class WorkController extends GetxController {
  WorkController({required this.repository});

  final WorkExperienceRepository repository;

  final works = <WorkExperience>[].obs;
  int? lastProfileId;

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    works.assignAll(await repository.getByProfile(profileId));
  }

  Future<void> save(WorkExperience experience) async {
    await repository.create(experience);
    await load(experience.profileId);
  }

  Future<void> updateWork(WorkExperience experience) async {
    await repository.update(experience);
    await load(experience.profileId);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }
}
