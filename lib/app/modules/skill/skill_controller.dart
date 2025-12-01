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

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    try {
      final loaded = await repository.getByProfile(profileId);
      loaded.sort(_compareSkills);
      skills.assignAll(loaded);
    } catch (error) {
      Get.snackbar('خطا', 'بارگذاری مهارت‌ها انجام نشد: $error');
    }
  }

  Future<void> save(Skill skill) async {
    final nextOrder = _nextSortOrder();
    await repository.create(
      Skill(
        profileId: skill.profileId,
        name: skill.name,
        level: skill.level,
        category: skill.category,
        sortOrder: nextOrder,
      ),
    );
    await load(skill.profileId);
  }

  Future<void> updateSkill(Skill skill) async {
    if (skill.id == null) {
      throw ArgumentError('شناسه مهارت برای ویرایش الزامی است');
    }

    await repository.update(skill);
    await load(skill.profileId);
  }

  int _compareSkills(Skill a, Skill b) {
    final categoryDiff = _categoryIndex(a.category) - _categoryIndex(b.category);
    if (categoryDiff != 0) {
      return categoryDiff;
    }

    return a.sortOrder.compareTo(b.sortOrder);
  }

  int _categoryIndex(String category) {
    final index = _categoryPriority.indexOf(category);
    return index >= 0 ? index : _categoryPriority.length;
  }

  int _nextSortOrder() {
    if (skills.isEmpty) {
      return 0;
    }

    return skills.map((skill) => skill.sortOrder).fold<int>(0, (prev, element) {
      if (element > prev) return element;
      return prev;
    }) + 1;
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }
}
