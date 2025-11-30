import 'package:get/get.dart';

import '../../data/models/certification.dart';
import '../../data/repositories/certification_repository.dart';

class CertificationController extends GetxController {
  CertificationController({required this.repository});

  final CertificationRepository repository;
  final RxList<Certification> certifications = <Certification>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    final items = await repository.getAll();
    certifications.assignAll(items);
  }

  Future<void> save(Certification certification) async {
    final id = await repository.create(certification);
    certifications.insert(0, certification.copyWith(id: id));
  }

  Future<void> updateCertification(Certification certification) async {
    await repository.update(certification);
    final index = certifications.indexWhere((item) => item.id == certification.id);
    if (index == -1) return;
    certifications[index] = certification;
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    certifications.removeWhere((item) => item.id == id);
  }
}
