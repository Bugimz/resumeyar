import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/work_experience.dart';
import '../../utils/validators.dart';
import 'work_controller.dart';

class WorkView extends GetView<WorkController> {
  WorkView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController = TextEditingController(text: '1');
  final TextEditingController companyController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Rxn<WorkExperience> editingExperience = Rxn<WorkExperience>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingExperience.value = null;
    companyController.clear();
    positionController.clear();
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

    final experience = WorkExperience(
      id: editingExperience.value?.id,
      profileId: profileId,
      company: companyController.text,
      position: positionController.text,
      startDate: startDateController.text,
      endDate: endDateController.text,
      description: descriptionController.text,
    );

    if (editingExperience.value == null) {
      await controller.save(experience);
    } else {
      await controller.update(experience);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('work_experience'.tr),
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
                    controller: companyController,
                    decoration: InputDecoration(labelText: 'company_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: positionController,
                    decoration: InputDecoration(labelText: 'position_label'.tr),
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
                              editingExperience.value == null
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
              'work_experiences_title'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final works = controller.works;

              if (works.isEmpty) {
                return Text('no_work_experiences'.tr);
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: works.length,
                itemBuilder: (context, index) {
                  final experience = works[index];
                  return Card(
                    child: ListTile(
                      title: Text('${experience.company} • ${experience.position}'),
                      subtitle:
                          Text('${experience.startDate} - ${experience.endDate}\n${experience.description}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editingExperience.value = experience;
                              profileIdController.text =
                                  experience.profileId.toString();
                              companyController.text = experience.company;
                              positionController.text = experience.position;
                              startDateController.text = experience.startDate;
                              endDateController.text = experience.endDate;
                              descriptionController.text = experience.description;
                              _updateFormValidity();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              if (experience.id != null) {
                                await controller.delete(experience.id!);
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
