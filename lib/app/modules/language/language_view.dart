import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/language.dart';
import '../../utils/validators.dart';
import '../../utils/widgets/section_card.dart';
import 'language_controller.dart';

class LanguageView extends GetView<LanguageController> {
  LanguageView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController proficiencyController = TextEditingController();
  final Rxn<Language> editingLanguage = Rxn<Language>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingLanguage.value = null;
    nameController.clear();
    proficiencyController.clear();
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

    final language = Language(
      id: editingLanguage.value?.id,
      name: nameController.text,
      proficiency: proficiencyController.text,
    );

    if (editingLanguage.value == null) {
      await controller.save(language);
    } else {
      await controller.updateLanguage(language);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('languages'.tr)),
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
                    SectionCard(
                      title: 'languages'.tr,
                      subtitle: 'language_form_subtitle'.tr,
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'language_name_label'.tr,
                                prefixIcon: const Icon(Icons.translate),
                              ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                            child: TextFormField(
                              controller: proficiencyController,
                              decoration: InputDecoration(
                                labelText: 'language_level_label'.tr,
                                prefixIcon: const Icon(Icons.bar_chart),
                              ),
                                validator: FormValidators.requiredField,
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
                                    () => ElevatedButton.icon(
                                      onPressed:
                                          isFormValid.value ? _submit : null,
                                      icon: Icon(editingLanguage.value == null
                                          ? Icons.save_outlined
                                          : Icons.check_circle_outline),
                                      label: Text(
                                        editingLanguage.value == null
                                            ? 'save'.tr
                                            : 'update'.tr,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _resetForm,
                                    icon: const Icon(Icons.refresh),
                                    label: Text('clear'.tr),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SectionCard(
                      title: 'languages'.tr,
                      subtitle: 'language_list_subtitle'.tr,
                      child: Obx(() {
                        final languages = controller.languages;
                        if (languages.isEmpty) {
                          return Text('no_languages'.tr);
                        }

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: languages
                              .map(
                                (language) => SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth / 2) - 20
                                      : constraints.maxWidth,
                                  child: _LanguageCard(
                                    language: language,
                                    onEdit: _editLanguage,
                                    onDelete: () => controller.delete(language.id!),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }),
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

  void _editLanguage(Language language) {
    editingLanguage.value = language;
    nameController.text = language.name;
    proficiencyController.text = language.proficiency;
    _updateFormValidity();
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.onEdit,
    required this.onDelete,
  });

  final Language language;
  final ValueChanged<Language> onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.language_outlined),
        title: Text(language.name),
        subtitle:
            Text('${'language_level_label'.tr}: ${language.proficiency}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(language),
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
