import 'package:get/get.dart';

import '../../data/models/resume_profile.dart';
import '../../data/repositories/resume_profile_repository.dart';

class ProfileController extends GetxController {
  ProfileController({required this.repository});

  final ResumeProfileRepository repository;

  Future<List<ResumeProfile>> load() {
    return repository.getAll();
  }

  Future<int> save(ResumeProfile profile) {
    return repository.create(profile);
  }

  Future<int> update(ResumeProfile profile) {
    return repository.update(profile);
  }
}
