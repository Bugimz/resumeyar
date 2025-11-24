import 'package:get/get.dart';

import '../../data/repositories/project_repository.dart';
import 'project_controller.dart';

class ProjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectRepository>(ProjectRepository.new);
    Get.lazyPut<ProjectController>(
      () => ProjectController(repository: Get.find()),
    );
  }
}
