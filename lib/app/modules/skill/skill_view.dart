import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/skill.dart';
import 'skill_controller.dart';

class SkillView extends GetView<SkillController> {
  SkillView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController = TextEditingController(text: '1');
  final TextEditingController nameController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final Rxn<Skill> editingSkill = Rxn<Skill>();

  void _resetForm() {
    editingSkill.value = null;
    nameController.clear();
    levelController.clear();
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

    final skill = Skill(
      id: editingSkill.value?.id,
      profileId: profileId,
      name: nameController.text,
      level: levelController.text,
    );

    if (editingSkill.value == null) {
      await controller.save(skill);
    } else {
      await controller.update(skill);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
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
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Skill Name'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: levelController,
                    decoration: const InputDecoration(labelText: 'Level'),
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
                            editingSkill.value == null ? 'Save' : 'Update',
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
              'Skills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final skills = controller.skills;

              if (skills.isEmpty) {
                return const Text('No skills found.');
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  final skill = skills[index];
                  return Card(
                    child: ListTile(
                      title: Text(skill.name),
                      subtitle: Text('Level: ${skill.level}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editingSkill.value = skill;
                              profileIdController.text = skill.profileId.toString();
                              nameController.text = skill.name;
                              levelController.text = skill.level;
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              if (skill.id != null) {
                                await controller.delete(skill.id!);
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
