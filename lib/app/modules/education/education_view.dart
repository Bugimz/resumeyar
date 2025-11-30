import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../data/models/education.dart';
import '../../utils/validators.dart';
import 'education_controller.dart';

class EducationView extends GetView<EducationController> {
  EducationView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController = TextEditingController(text: '1');
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController fieldController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController gpaController = TextEditingController();
  final TextEditingController honorController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController sortOrderController = TextEditingController();
  final Rxn<Education> editingEducation = Rxn<Education>();
  final RxBool isFormValid = false.obs;
  final RxBool showGpa = false.obs;
  final RxList<String> honors = <String>[].obs;
  final RxList<String> courses = <String>[].obs;

  void _resetForm() {
    editingEducation.value = null;
    schoolController.clear();
    degreeController.clear();
    fieldController.clear();
    startDateController.clear();
    endDateController.clear();
    descriptionController.clear();
    gpaController.clear();
    honorController.clear();
    courseController.clear();
    sortOrderController.clear();
    honors.clear();
    courses.clear();
    showGpa.value = false;
    isFormValid.value = false;
  }

  String _formatDate(DateTime date) {
    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1300, 1),
      lastDate: Jalali(1500, 12),
    );

    if (picked != null) {
      controller.text = _formatDate(picked.toDateTime());
      _updateFormValidity();
    }
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

    final parsedSortOrder = int.tryParse(sortOrderController.text);
    final defaultSortOrder = controller.educations
        .where((element) => element.school == schoolController.text)
        .length;

    final education = Education(
      id: editingEducation.value?.id,
      profileId: profileId,
      school: schoolController.text,
      degree: degreeController.text,
      fieldOfStudy: fieldController.text,
      startDate: startDateController.text,
      endDate: endDateController.text,
      description: descriptionController.text,
      gpa: double.tryParse(gpaController.text),
      showGpa: showGpa.value,
      honors: honors.toList(),
      courses: courses.toList(),
      sortOrder: parsedSortOrder ?? defaultSortOrder,
    );

    if (editingEducation.value == null) {
      await controller.save(education);
    } else {
      await controller.updateEducation(education);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('education'.tr),
      ),
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
                              controller: schoolController,
                              decoration:
                                  InputDecoration(labelText: 'school_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: degreeController,
                              decoration:
                                  InputDecoration(labelText: 'degree_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: fieldController,
                              decoration: InputDecoration(
                                labelText: 'field_of_study_label'.tr,
                              ),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: startDateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'start_date'.tr,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _pickDate(
                                    context,
                                    startDateController,
                                  ),
                                ),
                              ),
                              validator: FormValidators.date,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: endDateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'end_date'.tr,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _pickDate(
                                    context,
                                    endDateController,
                                  ),
                                ),
                              ),
                              validator: (_) => FormValidators.startBeforeEnd(
                                start: startDateController.text,
                                end: endDateController.text,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                  labelText: 'description_label'.tr),
                              validator: FormValidators.requiredField,
                              maxLines: 3,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Obx(() => ElevatedButton(
                                      onPressed:
                                          isFormValid.value ? _submit : null,
                                      child: Text(
                                        editingEducation.value == null
                                            ? 'save'.tr
                                            : 'update'.tr,
                                      ),
                                    )),
                                TextButton(
                                  onPressed: _resetForm,
                                  child: Text('clear'.tr),
                                ),
                                OutlinedButton(
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
                    Text(
                      'education_history_title'.tr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final educations = controller.educations;

                      if (educations.isEmpty) {
                        return Text('no_education_history'.tr);
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: educations.length,
                        itemBuilder: (context, index) {
                          final education = educations[index];
                          return Card(
                            child: ListTile(
                              title: Text('${education.school} • ${education.degree}'),
                              subtitle: Text(
                                '${education.fieldOfStudy}\n${education.startDate} - ${education.endDate}\n${education.description}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      editingEducation.value = education;
                                      profileIdController.text =
                                          education.profileId.toString();
                                      schoolController.text = education.school;
                                      degreeController.text = education.degree;
                                      fieldController.text = education.fieldOfStudy;
                                      startDateController.text = education.startDate;
                                      endDateController.text = education.endDate;
                                      descriptionController.text =
                                          education.description;
                                      _updateFormValidity();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      if (education.id != null) {
                                        await controller.delete(education.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
}

class _ChipEditor extends StatelessWidget {
  const _ChipEditor({
    required this.label,
    required this.controller,
    required this.values,
    required this.onAdd,
  });

  final String label;
  final TextEditingController controller;
  final RxList<String> values;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
            ),
          ),
          onFieldSubmitted: (_) => onAdd(),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 6,
            children: values
                .map(
                  (value) => InputChip(
                    label: Text(value),
                    onDeleted: () => values.remove(value),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
