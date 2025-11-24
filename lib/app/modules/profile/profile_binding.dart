import 'package:get/get.dart';

import '../../data/repositories/resume_profile_repository.dart';
import 'profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResumeProfileRepository>(ResumeProfileRepository.new);
    Get.lazyPut<ProfileController>(
      () => ProfileController(repository: Get.find()),
    );
  }
}
