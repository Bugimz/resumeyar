import 'package:get/get.dart';

import '../../data/models/project.dart';
import '../../data/repositories/project_repository.dart';

class ProjectController extends GetxController {
  ProjectController({required this.repository});

  final ProjectRepository repository;

  Future<List<Project>> load(int profileId) {
    return repository.getByProfile(profileId);
  }

  Future<int> save(Project project) {
    return repository.create(project);
  }

  Future<int> update(Project project) {
    return repository.update(project);
  }
}
