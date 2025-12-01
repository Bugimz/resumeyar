import 'package:get/get.dart';

import '../../data/models/language.dart';
import '../../data/repositories/language_repository.dart';

class LanguageController extends GetxController {
  LanguageController({required this.repository});

  final LanguageRepository repository;
  final RxList<Language> languages = <Language>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final items = await repository.getAll();
    languages.assignAll(items);
  }

  Future<void> save(Language language) async {
    final id = await repository.create(language);
    languages.insert(0, language.copyWith(id: id));
  }

  Future<void> updateLanguage(Language language) async {
    await repository.update(language);
    final index = languages.indexWhere((item) => item.id == language.id);
    if (index == -1) return;
    languages[index] = language;
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    languages.removeWhere((item) => item.id == id);
  }
}
