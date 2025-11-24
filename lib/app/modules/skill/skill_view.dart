import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/skill.dart';
import '../../utils/validators.dart';
import 'skill_controller.dart';

class SkillView extends GetView<SkillController> {
  SkillView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController = TextEditingController(text: '1');
  final TextEditingController nameController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final Rxn<Skill> editingSkill = Rxn<Skill>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingSkill.value = null;
    nameController.clear();
    levelController.clear();
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

    final skill = Skill(
      id: editingSkill.value?.id,
      profileId: profileId,
      name: nameController.text,
      level: levelController.text,
    );

    if (editingSkill.value == null) {
      await controller.save(skill);
    } else {
      await controller.updateSkill(skill);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('skills'.tr),
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
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'skill_name_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: levelController,
                    decoration: InputDecoration(labelText: 'level_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Obx(() => ElevatedButton(
                            onPressed: isFormValid.value ? _submit : null,
                            child: Text(
                              editingSkill.value == null
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
              'skills'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final skills = controller.skills;

              if (skills.isEmpty) {
                return Text('no_skills'.tr);
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
                          subtitle:
                              Text('${'level_label'.tr}: ${skill.level}'),
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
                              _updateFormValidity();
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
