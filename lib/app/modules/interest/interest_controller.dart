import 'package:get/get.dart';

import '../../data/models/interest.dart';
import '../../data/repositories/interest_repository.dart';

class InterestController extends GetxController {
  InterestController({required this.repository});

  final InterestRepository repository;

  final interests = <Interest>[].obs;
  int? lastProfileId;

  int _nextSortOrder() {
    if (interests.isEmpty) {
      return 0;
    }
    return interests.map((interest) => interest.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    interests.assignAll(await repository.getByProfile(profileId));
  }

  Future<void> save(Interest interest) async {
    await repository.create(
        interest.copyWith(sortOrder: interest.sortOrder >= 0 ? interest.sortOrder : _nextSortOrder()));
    await load(interest.profileId);
  }

  Future<void> updateInterest(Interest interest) async {
    await repository.update(interest);
    await load(interest.profileId);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }
}
