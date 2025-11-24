import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/work_experience.dart';
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

  void _resetForm() {
    editingExperience.value = null;
    companyController.clear();
    positionController.clear();
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
        title: const Text('Work Experience'),
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
                    controller: companyController,
                    decoration: const InputDecoration(labelText: 'Company'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: positionController,
                    decoration: const InputDecoration(labelText: 'Position'),
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
                            editingExperience.value == null ? 'Save' : 'Update',
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
              'Work Experiences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final works = controller.works;

              if (works.isEmpty) {
                return const Text('No work experiences found.');
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
