import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/education.dart';
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

  void _resetForm() {
    editingEducation.value = null;
    schoolController.clear();
    degreeController.clear();
    fieldController.clear();
    startDateController.clear();
    endDateController.clear();
    descriptionController.clear();
  }

  int? _parseProfileId() {
    final profileId = int.tryParse(profileIdController.text);
    if (profileId == null) {
      Get.snackbar('Validation', 'Profile ID must be a number');
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
        title: const Text('Education'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: profileIdController,
                    decoration: const InputDecoration(labelText: 'Profile ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: schoolController,
                    decoration: const InputDecoration(labelText: 'School'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: degreeController,
                    decoration: const InputDecoration(labelText: 'Degree'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: fieldController,
                    decoration: const InputDecoration(labelText: 'Field of Study'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: startDateController,
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: endDateController,
                    decoration: const InputDecoration(labelText: 'End Date'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _submit,
                        child: Obx(
                          () => Text(
                            editingEducation.value == null ? 'Save' : 'Update',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _resetForm,
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _loadList,
                        child: const Text('Load List'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Education History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final educations = controller.educations;

              if (educations.isEmpty) {
                return const Text('No education history found.');
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
