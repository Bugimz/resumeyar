import 'package:get/get.dart';

import '../../data/models/certification.dart';
import '../../data/repositories/certification_repository.dart';

class CertificationController extends GetxController {
  CertificationController({required this.repository});

  final CertificationRepository repository;

  final certifications = <Certification>[].obs;
  int? lastProfileId;

  int _nextSortOrder() {
    if (certifications.isEmpty) {
      return 0;
    }
    return certifications.map((cert) => cert.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  void onInit() {
    super.onInit();
    load(1);
  }

  Future<void> load(int profileId) async {
    lastProfileId = profileId;
    certifications.assignAll(await repository.getByProfile(profileId));
  }

  Future<void> save(Certification certification) async {
    await repository.create(
      certification.copyWith(sortOrder: certification.sortOrder >= 0 ? certification.sortOrder : _nextSortOrder()),
    );
    await load(certification.profileId);
  }

  Future<void> updateCertification(Certification certification) async {
    await repository.update(certification);
    await load(certification.profileId);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    if (lastProfileId != null) {
      await load(lastProfileId!);
    }
  }
}
