import 'package:get/get.dart';

import '../../data/models/resume_profile.dart';
import '../../data/repositories/resume_profile_repository.dart';

class ProfileController extends GetxController {
  ProfileController({required this.repository});

  final ResumeProfileRepository repository;

  final profiles = <ResumeProfile>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    isLoading.value = true;
    profiles.assignAll(await repository.getAll());
    isLoading.value = false;
  }

  Future<void> saveProfile(ResumeProfile profile) async {
    await repository.create(profile);
    await loadProfiles();
  }

  Future<void> updateProfile(ResumeProfile profile) async {
    await repository.update(profile);
    await loadProfiles();
  }

  Future<void> deleteProfile(int id) async {
    await repository.delete(id);
    await loadProfiles();
  }
}
