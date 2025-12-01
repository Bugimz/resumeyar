import 'package:get/get.dart';

import '../../data/repositories/interest_repository.dart';
import 'interest_controller.dart';

class InterestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterestRepository>(InterestRepository.new);
    Get.lazyPut<InterestController>(
      () => InterestController(repository: Get.find()),
    );
  }
}
