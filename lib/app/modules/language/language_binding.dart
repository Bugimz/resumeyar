import 'package:get/get.dart';

import '../../data/repositories/language_repository.dart';
import 'language_controller.dart';

class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageRepository>(LanguageRepository.new);
    Get.lazyPut<LanguageController>(
      () => LanguageController(repository: Get.find()),
    );
  }
}
