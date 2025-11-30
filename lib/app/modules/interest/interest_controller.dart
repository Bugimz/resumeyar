import 'package:get/get.dart';

import '../../data/models/interest.dart';

class InterestController extends GetxController {
  final RxList<Interest> interests = <Interest>[].obs;
  int _nextId = 1;

  Future<void> save(Interest interest) async {
    interests.add(interest.copyWith(id: _nextId++));
  }

  Future<void> updateInterest(Interest interest) async {
    final index = interests.indexWhere((item) => item.id == interest.id);
    if (index == -1) return;
    interests[index] = interest;
  }

  Future<void> delete(int id) async {
    interests.removeWhere((item) => item.id == id);
  }
}
