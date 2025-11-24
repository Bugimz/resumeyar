import 'package:get/get.dart';

import '../../data/repositories/work_experience_repository.dart';
import 'work_controller.dart';

class WorkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkExperienceRepository>(WorkExperienceRepository.new);
    Get.lazyPut<WorkController>(
      () => WorkController(repository: Get.find()),
    );
  }
}
