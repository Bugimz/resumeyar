import 'package:get/get.dart';

import '../../data/models/project.dart';
import '../../data/repositories/project_repository.dart';

class ProjectController extends GetxController {
  ProjectController({required this.repository});

  final ProjectRepository repository;

  final projects = <Project>[].obs;
  int? lastProfileId;

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    projects.assignAll(await repository.getByProfile(profileId));
  }

  Future<void> save(Project project) async {
    await repository.create(project);
    await load(project.profileId);
  }

  Future<void> updateProject(Project project) async {
    await repository.update(project);
    await load(project.profileId);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }
}
