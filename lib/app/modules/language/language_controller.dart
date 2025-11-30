import 'package:get/get.dart';

import '../../data/models/language.dart';
import '../../data/repositories/language_repository.dart';

class LanguageController extends GetxController {
  LanguageController({required this.repository});

  final LanguageRepository repository;

  final languages = <Language>[].obs;
  int? lastProfileId;

  int _nextSortOrder() {
    if (languages.isEmpty) {
      return 0;
    }
    return languages.map((lang) => lang.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    languages.assignAll(await repository.getByProfile(profileId));
  }

  Future<void> save(Language language) async {
    await repository.create(language.copyWith(sortOrder: language.sortOrder >= 0 ? language.sortOrder : _nextSortOrder()));
    await load(language.profileId);
  }

  Future<void> updateLanguage(Language language) async {
    await repository.update(language);
    await load(language.profileId);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }
}
