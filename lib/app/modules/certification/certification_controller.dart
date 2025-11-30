import 'package:get/get.dart';

import '../../data/models/certification.dart';

class CertificationController extends GetxController {
  final RxList<Certification> certifications = <Certification>[].obs;
  int _nextId = 1;

  Future<void> save(Certification certification) async {
    certifications.add(certification.copyWith(id: _nextId++));
  }

  Future<void> updateCertification(Certification certification) async {
    final index =
        certifications.indexWhere((item) => item.id == certification.id);
    if (index == -1) return;
    certifications[index] = certification;
  }

  Future<void> delete(int id) async {
    certifications.removeWhere((item) => item.id == id);
  }
}
