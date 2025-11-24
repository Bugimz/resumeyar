import 'package:get/get.dart';

import '../../data/repositories/skill_repository.dart';
import 'skill_controller.dart';

class SkillBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SkillRepository>(SkillRepository.new);
    Get.lazyPut<SkillController>(
      () => SkillController(repository: Get.find()),
    );
  }
}
