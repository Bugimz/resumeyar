import 'package:get/get.dart';

import '../../data/models/skill.dart';
import '../../data/repositories/skill_repository.dart';

class SkillController extends GetxController {
  SkillController({required this.repository});

  final SkillRepository repository;

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
      skills.assignAll(await repository.getByProfile(profileId));
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
