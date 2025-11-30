import 'package:get/get.dart';

import '../../data/models/interest.dart';
import '../../data/repositories/interest_repository.dart';

class InterestController extends GetxController {
  InterestController({required this.repository});

  final InterestRepository repository;
  final RxList<Interest> interests = <Interest>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    final items = await repository.getAll();
    interests.assignAll(items);
  }

  Future<void> save(Interest interest) async {
    final id = await repository.create(interest);
    interests.insert(0, interest.copyWith(id: id));
  }

  Future<void> updateInterest(Interest interest) async {
    await repository.update(interest);
    final index = interests.indexWhere((item) => item.id == interest.id);
    if (index == -1) return;
    interests[index] = interest;
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    interests.removeWhere((item) => item.id == id);
  }
}
