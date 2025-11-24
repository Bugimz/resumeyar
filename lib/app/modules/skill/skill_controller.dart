import 'package:get/get.dart';

import '../../data/models/skill.dart';
import '../../data/repositories/skill_repository.dart';

class SkillController extends GetxController {
  SkillController({required this.repository});

  final SkillRepository repository;

  final skills = <Skill>[].obs;
  int? lastProfileId;

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    skills.assignAll(await repository.getByProfile(profileId));
  }

  Future<void> save(Skill skill) async {
    await repository.create(skill);
    await load(skill.profileId);
  }

  Future<void> updateSkill(Skill skill) async {
    await repository.update(skill);
    await load(skill.profileId);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }
}
