import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/language.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import 'language_controller.dart';

class LanguageView extends GetView<LanguageController> {
  LanguageView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController = TextEditingController(text: '1');
  final TextEditingController nameController = TextEditingController();
  final RxString selectedLevel = 'C1'.obs;
  final Rxn<Language> editingLanguage = Rxn<Language>();
  final RxBool isFormValid = false.obs;

  static const List<String> _levels = ['Native', 'C2', 'C1', 'B2', 'B1', 'A2', 'A1'];

  void _resetForm() {
    editingLanguage.value = null;
    nameController.clear();
    selectedLevel.value = 'C1';
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

    final language = Language(
      id: editingLanguage.value?.id,
      profileId: profileId,
      name: nameController.text,
      level: selectedLevel.value,
      sortOrder: editingLanguage.value?.sortOrder ?? -1,
    );

    if (editingLanguage.value == null) {
      await controller.save(language);
    } else {
      await controller.updateLanguage(language);
    }

    _resetForm();
  }

  void _editLanguage(Language language) {
    editingLanguage.value = language;
    profileIdController.text = language.profileId.toString();
    nameController.text = language.name;
    selectedLevel.value = language.level;
    _updateFormValidity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('languages'.tr),
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
                              decoration: InputDecoration(labelText: 'language_name_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Obx(
                              () => DropdownButtonFormField<String>(
                                value: selectedLevel.value,
                                decoration: InputDecoration(labelText: 'language_level_label'.tr),
                                items: _levels
                                    .map(
                                      (level) => DropdownMenuItem(
                                        value: level,
                                        child: Text(level),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    selectedLevel.value = value;
                                  }
                                },
                              ),
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
                                      child: Text(editingLanguage.value == null ? 'save'.tr : 'update'.tr),
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
                      () => controller.languages.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text('no_languages'.tr),
                              ),
                            )
                          : Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: controller.languages
                                  .map(
                                    (language) => SizedBox(
                                      width: isWide ? (constraints.maxWidth / 2) - 28 : constraints.maxWidth,
                                      child: _LanguageCard(
                                        language: language,
                                        onEdit: _editLanguage,
                                        onDelete: () => controller.delete(language.id!),
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

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.language, required this.onEdit, required this.onDelete});

  final Language language;
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text('${'language_level_label'.tr}: ${language.level}'),
                ],
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
      ),
    );
  }
}
