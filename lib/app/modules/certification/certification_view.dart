import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/certification.dart';
import '../../utils/validators.dart';
import 'certification_controller.dart';

class CertificationView extends GetView<CertificationController> {
  CertificationView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController issuerController = TextEditingController();
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController credentialUrlController = TextEditingController();
  final Rxn<Certification> editingCertification = Rxn<Certification>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingCertification.value = null;
    titleController.clear();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final certification = Certification(
      id: editingCertification.value?.id,
      title: titleController.text,
      issuer: issuerController.text,
      issueDate: issueDateController.text,
      credentialUrl: credentialUrlController.text,
    );

    if (editingCertification.value == null) {
      await controller.save(certification);
    } else {
      await controller.updateCertification(certification);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('certifications'.tr)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final double fieldWidth = isWide
              ? (constraints.maxWidth / 2) - 28
              : constraints.maxWidth;

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
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'certification_name_label'.tr,
                              ),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: issuerController,
                              decoration: InputDecoration(
                                labelText: 'certification_issuer_label'.tr,
                              ),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: issueDateController,
                              decoration: InputDecoration(
                                labelText: 'issue_date_label'.tr,
                              ),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: credentialUrlController,
                              decoration: InputDecoration(
                                labelText: 'credential_url_label'.tr,
                              ),
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Obx(
                                  () => ElevatedButton(
                                    onPressed: isFormValid.value ? _submit : null,
                                    child: Text(
                                      editingCertification.value == null
                                          ? 'save'.tr
                                          : 'update'.tr,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _resetForm,
                                  child: Text('clear'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('certifications'.tr,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Obx(() {
                      final certifications = controller.certifications;
                      if (certifications.isEmpty) {
                        return Text('no_certifications'.tr);
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: certifications
                            .map(
                              (certification) => SizedBox(
                                width: isWide
                                    ? (constraints.maxWidth / 2) - 28
                                    : constraints.maxWidth,
                                child: _CertificationCard(
                                  certification: certification,
                                  onEdit: _editCertification,
                                  onDelete: () => controller.delete(certification.id!),
                                  onOpenCredential: certification.credentialUrl.isEmpty
                                      ? null
                                      : () => _openCredentialUrl(
                                            certification.credentialUrl,
                                          ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _editCertification(Certification certification) {
    editingCertification.value = certification;
    titleController.text = certification.title;
    issuerController.text = certification.issuer;
    issueDateController.text = certification.issueDate;
    credentialUrlController.text = certification.credentialUrl;
    _updateFormValidity();
  }

  void _openCredentialUrl(String url) {
    Get.snackbar('credential_url_label'.tr, url);
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
  final ValueChanged<Certification> onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenCredential;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(certification.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(certification.issuer),
            Text(certification.issueDate),
            if (certification.credentialUrl.isNotEmpty)
              Text(
                certification.credentialUrl,
                style: const TextStyle(color: Colors.blue),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onOpenCredential != null)
              IconButton(
                icon: const Icon(Icons.link),
                onPressed: onOpenCredential,
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(certification),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
