import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/interest.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import 'interest_controller.dart';

class InterestView extends GetView<InterestController> {
  InterestView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController = TextEditingController(text: '1');
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final Rxn<Interest> editingInterest = Rxn<Interest>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingInterest.value = null;
    titleController.clear();
    detailsController.clear();
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

    final interest = Interest(
      id: editingInterest.value?.id,
      profileId: profileId,
      title: titleController.text,
      details: detailsController.text,
      sortOrder: editingInterest.value?.sortOrder ?? -1,
    );

    if (editingInterest.value == null) {
      await controller.save(interest);
    } else {
      await controller.updateInterest(interest);
    }

    _resetForm();
  }

  void _editInterest(Interest interest) {
    editingInterest.value = interest;
    profileIdController.text = interest.profileId.toString();
    titleController.text = interest.title;
    detailsController.text = interest.details;
    _updateFormValidity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('interests'.tr),
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
                              controller: titleController,
                              decoration: InputDecoration(labelText: 'interest_title_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: detailsController,
                              decoration: InputDecoration(
                                labelText: 'interest_details_label'.tr,
                                hintText: 'interest_details_hint'.tr,
                              ),
                              maxLines: 3,
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
                                      child: Text(editingInterest.value == null ? 'save'.tr : 'update'.tr),
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
                      () => controller.interests.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text('no_interests'.tr),
                              ),
                            )
                          : Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: controller.interests
                                  .map(
                                    (interest) => SizedBox(
                                      width: isWide ? (constraints.maxWidth / 2) - 28 : constraints.maxWidth,
                                      child: _InterestCard(
                                        interest: interest,
                                        onEdit: _editInterest,
                                        onDelete: () => controller.delete(interest.id!),
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

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.interest, required this.onEdit, required this.onDelete});

  final Interest interest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                    interest.title,
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
            if (interest.details.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(interest.details),
            ],
          ],
        ),
      ),
    );
  }
}
