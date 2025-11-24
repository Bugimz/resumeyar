import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final Rxn<Education> editingEducation = Rxn<Education>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingEducation.value = null;
    schoolController.clear();
    degreeController.clear();
    fieldController.clear();
    startDateController.clear();
    endDateController.clear();
    descriptionController.clear();
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

    final education = Education(
      id: editingEducation.value?.id,
      profileId: profileId,
      school: schoolController.text,
      degree: degreeController.text,
      fieldOfStudy: fieldController.text,
      startDate: startDateController.text,
      endDate: endDateController.text,
      description: descriptionController.text,
    );

    if (editingEducation.value == null) {
      await controller.save(education);
    } else {
      await controller.update(education);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('education'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    controller: profileIdController,
                    decoration: InputDecoration(labelText: 'profile_id'.tr),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.numeric,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: schoolController,
                    decoration: InputDecoration(labelText: 'school_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: degreeController,
                    decoration: InputDecoration(labelText: 'degree_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: fieldController,
                    decoration: InputDecoration(
                      labelText: 'field_of_study_label'.tr,
                    ),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: startDateController,
                    decoration: InputDecoration(labelText: 'start_date'.tr),
                    validator: FormValidators.date,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: endDateController,
                    decoration: InputDecoration(labelText: 'end_date'.tr),
                    validator: (_) => FormValidators.startBeforeEnd(
                      start: startDateController.text,
                      end: endDateController.text,
                    ),
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'description_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Obx(() => ElevatedButton(
                            onPressed: isFormValid.value ? _submit : null,
                            child: Text(
                              editingEducation.value == null
                                  ? 'save'.tr
                                  : 'update'.tr,
                            ),
                          )),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _resetForm,
                        child: Text('clear'.tr),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _loadList,
                        child: Text('load_list'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'education_history_title'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              descriptionController.text = education.description;
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
    );
  }
}
