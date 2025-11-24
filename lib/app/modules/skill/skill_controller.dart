import 'package:get/get.dart';

import '../../data/models/skill.dart';
import '../../data/repositories/skill_repository.dart';

class SkillController extends GetxController {
  SkillController({required this.repository});

  final SkillRepository repository;

  Future<List<Skill>> load(int profileId) {
    return repository.getByProfile(profileId);
  }

  Future<int> save(Skill skill) {
    return repository.create(skill);
  }

  Future<int> update(Skill skill) {
    return repository.update(skill);
  }
}
