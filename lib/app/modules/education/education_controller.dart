import 'package:get/get.dart';

import '../../data/models/education.dart';
import '../../data/repositories/education_repository.dart';

class EducationController extends GetxController {
  EducationController({required this.repository});

  final EducationRepository repository;

  final educations = <Education>[].obs;
  int? lastProfileId;

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    educations.assignAll(await repository.getByProfile(profileId));
  }

  Future<void> save(Education education) async {
    await repository.create(education);
    await load(education.profileId);
  }

  Future<void> updateEducation(Education education) async {
    await repository.update(education);
    await load(education.profileId);
  }

  Future<void> updateSortOrder(Education education, int delta) async {
    if (education.id == null) {
      return;
    }

    final newOrder = (education.sortOrder + delta).clamp(0, 1000000).toInt();
    final updated = education.copyWith(sortOrder: newOrder);
    await repository.update(updated);
    await load(updated.profileId);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }
}
