import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/project.dart';
import '../../utils/validators.dart';
import 'project_controller.dart';

class ProjectView extends GetView<ProjectController> {
  ProjectView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController = TextEditingController(text: '1');
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final Rxn<Project> editingProject = Rxn<Project>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingProject.value = null;
    titleController.clear();
    descriptionController.clear();
    linkController.clear();
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

    final project = Project(
      id: editingProject.value?.id,
      profileId: profileId,
      title: titleController.text,
      description: descriptionController.text,
      link: linkController.text,
    );

    if (editingProject.value == null) {
      await controller.save(project);
    } else {
      await controller.updateProject(project);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('projects'.tr),
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
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'title_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'description_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: linkController,
                    decoration: InputDecoration(labelText: 'link_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Obx(() => ElevatedButton(
                            onPressed: isFormValid.value ? _submit : null,
                            child: Text(
                              editingProject.value == null
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
              'projects'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final projects = controller.projects;

              if (projects.isEmpty) {
                return Text('no_projects'.tr);
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Card(
                    child: ListTile(
                      title: Text(project.title),
                      subtitle: Text('${project.description}\n${project.link}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editingProject.value = project;
                              profileIdController.text = project.profileId.toString();
                              titleController.text = project.title;
                              descriptionController.text = project.description;
                              linkController.text = project.link;
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              if (project.id != null) {
                                await controller.delete(project.id!);
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
