import 'package:get/get.dart';

import '../../data/models/skill.dart';
import '../../data/repositories/skill_repository.dart';

class SkillController extends GetxController {
  SkillController({required this.repository});

  final SkillRepository repository;

  // ترتیب دلخواه برای دسته‌بندی‌ها تا مهارت‌ها همیشه با نظم یکسانی نمایش داده شوند
  static const List<String> _categoryPriority = <String>[
    'General',
    'Languages',
    'Frameworks',
    'Tools',
    'Databases',
    'Other',
  ];

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
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    try {
      final loaded = await repository.getByProfile(profileId);
      final normalized = loaded
          .map(
            (skill) => Skill(
              id: skill.id,
              profileId: skill.profileId,
              name: skill.name,
              level: skill.level,
              category: _normalizeCategory(skill.category),
              sortOrder: skill.sortOrder,
            ),
          )
          .toList();
      normalized.sort(_compareSkills);
      skills.assignAll(normalized);
    } catch (error) {
      Get.snackbar('خطا', 'بارگذاری مهارت‌ها انجام نشد: $error');
    }
  }

  Future<void> save(Skill skill) async {
    final nextOrder = await _nextSortOrder(skill.profileId);
    await repository.create(
      Skill(
        profileId: skill.profileId,
        name: skill.name,
        level: skill.level,
        category: _normalizeCategory(skill.category),
        sortOrder: nextOrder,
      ),
    );
    await load(skill.profileId);
  }

  Future<void> updateSkill(Skill skill) async {
    if (skill.id == null) {
      throw ArgumentError('شناسه مهارت برای ویرایش الزامی است');
    }

    await repository.update(
      Skill(
        id: skill.id,
        profileId: skill.profileId,
        name: skill.name,
        level: skill.level,
        category: _normalizeCategory(skill.category),
        sortOrder: skill.sortOrder,
      ),
    );
    await load(skill.profileId);
  }

  int _compareSkills(Skill a, Skill b) {
    final categoryDiff = _categoryIndex(a.category) - _categoryIndex(b.category);
    if (categoryDiff != 0) {
      return categoryDiff;
    }

    return a.sortOrder.compareTo(b.sortOrder);
  }

  String _normalizeCategory(String category) {
    final trimmed = category.trim();
    return trimmed.isEmpty ? 'General' : trimmed;
  }

  int _categoryIndex(String category) {
    final index = _categoryPriority.indexOf(category);
    return index >= 0 ? index : _categoryPriority.length;
  }

  Future<int> _nextSortOrder(int profileId) async {
    if (skills.isNotEmpty && lastProfileId == profileId) {
      return _maxSortOrder(skills) + 1;
    }

    final existing = await repository.getByProfile(profileId);
    if (existing.isEmpty) {
      return 0;
    }

    return _maxSortOrder(existing) + 1;
  }

  int _maxSortOrder(List<Skill> source) =>
      source.map((skill) => skill.sortOrder).fold<int>(0, (prev, element) {
        if (element > prev) return element;
        return prev;
      });

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
