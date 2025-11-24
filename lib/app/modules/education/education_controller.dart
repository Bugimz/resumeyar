import 'package:get/get.dart';

import '../../data/models/education.dart';
import '../../data/repositories/education_repository.dart';

class EducationController extends GetxController {
  EducationController({required this.repository});

  final EducationRepository repository;

  Future<List<Education>> load(int profileId) {
    return repository.getByProfile(profileId);
  }

  Future<int> save(Education education) {
    return repository.create(education);
  }

  Future<int> update(Education education) {
    return repository.update(education);
  }
}
