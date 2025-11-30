import 'package:get/get.dart';

import '../../data/models/language.dart';

class LanguageController extends GetxController {
  final RxList<Language> languages = <Language>[].obs;
  int _nextId = 1;

  Future<void> save(Language language) async {
    languages.add(language.copyWith(id: _nextId++));
  }

  Future<void> updateLanguage(Language language) async {
    final index = languages.indexWhere((item) => item.id == language.id);
    if (index == -1) return;
    languages[index] = language;
  }

  Future<void> delete(int id) async {
    languages.removeWhere((item) => item.id == id);
  }
}
