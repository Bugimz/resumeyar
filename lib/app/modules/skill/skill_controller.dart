import 'package:get/get.dart';

import '../../data/models/skill.dart';
import '../../data/repositories/skill_repository.dart';

class SkillController extends GetxController {
  SkillController({required this.repository});

  final SkillRepository repository;

  final skills = <Skill>[].obs;
  int? lastProfileId;

  int _nextSortOrder(SkillCategory category) {
    final categorySkills = skills.where((skill) => skill.category == category);
    if (categorySkills.isEmpty) {
      return 0;
    }

    return categorySkills.map((skill) => skill.sortOrder).reduce((a, b) => a > b ? a : b) +
        1;
  }

  Skill? _skillById(int? id) {
    if (id == null) {
      return null;
    }

    for (final skill in skills) {
      if (skill.id == id) {
        return skill;
      }
    }
    return null;
  }

  List<Skill> _sortedSkills(List<Skill> items) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final categoryCompare =
          SkillCategory.values.indexOf(a.category) - SkillCategory.values.indexOf(b.category);
      if (categoryCompare != 0) {
        return categoryCompare;
      }
      return a.sortOrder.compareTo(b.sortOrder);
    });
    return sorted;
  }

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    skills.assignAll(_sortedSkills(await repository.getByProfile(profileId)));
  }

  Future<void> save(Skill skill) async {
    final preparedSkill = skill.copyWith(sortOrder: skill.sortOrder >= 0
        ? skill.sortOrder
        : _nextSortOrder(skill.category));
    await repository.create(preparedSkill);
    await load(skill.profileId);
  }

  Future<void> updateSkill(Skill skill) async {
    final current = _skillById(skill.id);
    var updatedSkill = skill;
    if (current != null && current.category != skill.category) {
      updatedSkill = skill.copyWith(sortOrder: _nextSortOrder(skill.category));
    }

    await repository.update(updatedSkill);
    await load(skill.profileId);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }

  Future<void> reorderWithinCategory({required Skill dragged, required Skill target}) async {
    if (dragged.category != target.category) {
      return;
    }

    final categorySkills = skills
        .where((skill) => skill.category == dragged.category)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final oldIndex = categorySkills.indexWhere((skill) => skill.id == dragged.id);
    final newIndex = categorySkills.indexWhere((skill) => skill.id == target.id);

    if (oldIndex == -1 || newIndex == -1 || oldIndex == newIndex) {
      return;
    }

    final moved = categorySkills.removeAt(oldIndex);
    categorySkills.insert(newIndex, moved);

    final updatedCategorySkills = <Skill>[];
    for (var i = 0; i < categorySkills.length; i++) {
      updatedCategorySkills.add(categorySkills[i].copyWith(sortOrder: i));
    }

    final otherSkills =
        skills.where((skill) => skill.category != dragged.category).toList(growable: true);
    skills.assignAll(_sortedSkills([...otherSkills, ...updatedCategorySkills]));

    await repository.updateMany(updatedCategorySkills);
  }
}
