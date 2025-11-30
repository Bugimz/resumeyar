import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/certification.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import 'certification_controller.dart';

class CertificationView extends GetView<CertificationController> {
  CertificationView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController = TextEditingController(text: '1');
  final TextEditingController nameController = TextEditingController();
  final TextEditingController issuerController = TextEditingController();
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController credentialUrlController = TextEditingController();
  final Rxn<Certification> editingCertification = Rxn<Certification>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingCertification.value = null;
    nameController.clear();
    issuerController.clear();
    issueDateController.clear();
    credentialUrlController.clear();
    isFormValid.value = false;
  }

  void _updateFormValidity() {
    final currentState = _formKey.currentState;
    if (currentState == null) {
      isFormValid.value = false;
      return;
    }

    isFormValid.value = currentState.validate();
  }

  int? _parseProfileId() {
    final profileId = int.tryParse(profileIdController.text);
    if (profileId == null) {
      Get.snackbar('error'.tr, 'invalid_number'.tr);
    }
    return profileId;
  }

  Future<void> _loadList() async {
    final profileId = _parseProfileId();
    if (profileId != null) {
      await controller.load(profileId);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileId = _parseProfileId();
    if (profileId == null) {
      return;
    }

    final certification = Certification(
      id: editingCertification.value?.id,
      profileId: profileId,
      name: nameController.text,
      issuer: issuerController.text,
      issueDate: issueDateController.text,
      credentialUrl: credentialUrlController.text,
      sortOrder: editingCertification.value?.sortOrder ?? -1,
    );

    if (editingCertification.value == null) {
      await controller.save(certification);
    } else {
      await controller.updateCertification(certification);
    }

    _resetForm();
  }

  void _editCertification(Certification certification) {
    editingCertification.value = certification;
    profileIdController.text = certification.profileId.toString();
    nameController.text = certification.name;
    issuerController.text = certification.issuer;
    issueDateController.text = certification.issueDate;
    credentialUrlController.text = certification.credentialUrl;
    _updateFormValidity();
  }

  Future<void> _openCredentialUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('error'.tr, 'invalid_link'.tr);
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('error'.tr, 'invalid_link'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('certifications'.tr),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final double fieldWidth = isWide ? (constraints.maxWidth / 2) - 28 : constraints.maxWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: profileIdController,
                              decoration: InputDecoration(labelText: 'profile_id'.tr),
                              keyboardType: TextInputType.number,
                              validator: FormValidators.numeric,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(labelText: 'certification_name_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: issuerController,
                              decoration: InputDecoration(labelText: 'certification_issuer_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: issueDateController,
                              decoration: InputDecoration(labelText: 'issue_date_label'.tr),
                              validator: FormValidators.date,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: credentialUrlController,
                              decoration: InputDecoration(labelText: 'credential_url_label'.tr),
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => FilledButton(
                                      onPressed: isFormValid.value ? _submit : null,
                                      child: Text(editingCertification.value == null ? 'save'.tr : 'update'.tr),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: _resetForm,
                                  child: Text('clear'.tr),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: _loadList,
                                  child: Text('load_list'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => controller.certifications.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text('no_certifications'.tr),
                              ),
                            )
                          : Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: controller.certifications
                                  .map(
                                    (certification) => SizedBox(
                                      width: isWide ? (constraints.maxWidth / 2) - 28 : constraints.maxWidth,
                                      child: _CertificationCard(
                                        certification: certification,
                                        onEdit: _editCertification,
                                        onDelete: () => controller.delete(certification.id!),
                                        onOpenCredential: certification.credentialUrl.isEmpty
                                            ? null
                                            : () => _openCredentialUrl(certification.credentialUrl),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CertificationCard extends StatelessWidget {
  const _CertificationCard({
    required this.certification,
    required this.onEdit,
    required this.onDelete,
    this.onOpenCredential,
  });

  final Certification certification;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenCredential;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardStroke),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    certification.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'update'.tr,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'delete'.tr,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${'certification_issuer_label'.tr}: ${certification.issuer}'),
            const SizedBox(height: 4),
            Text('${'issue_date_label'.tr}: ${certification.issueDate}'),
            if (certification.credentialUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onOpenCredential,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 18, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Text(
                      certification.credentialUrl,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.primaryDark, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
