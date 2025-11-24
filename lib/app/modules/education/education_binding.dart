import 'package:get/get.dart';

import '../../data/repositories/education_repository.dart';
import 'education_controller.dart';

class EducationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EducationRepository>(EducationRepository.new);
    Get.lazyPut<EducationController>(
      () => EducationController(repository: Get.find()),
    );
  }
}
