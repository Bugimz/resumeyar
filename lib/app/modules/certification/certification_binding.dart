import 'package:get/get.dart';

import '../../data/repositories/certification_repository.dart';
import 'certification_controller.dart';

class CertificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CertificationRepository>(CertificationRepository.new);
    Get.lazyPut<CertificationController>(
      () => CertificationController(repository: Get.find()),
    );
  }
}
