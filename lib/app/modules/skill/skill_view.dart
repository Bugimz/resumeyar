import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/skill.dart';
import '../../utils/validators.dart';
import '../../utils/widgets/section_card.dart';
import 'skill_controller.dart';

class SkillView extends StatefulWidget {
  SkillView({super.key});

  @override
  State<SkillView> createState() => _SkillViewState();
}

class _SkillViewState extends State<SkillView> {
  final SkillController controller = Get.find<SkillController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController =
      TextEditingController(text: '1');
  final TextEditingController nameController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController categoryController =
      TextEditingController(text: 'General');
  final Rxn<Skill> editingSkill = Rxn<Skill>();
  final RxBool isFormValid = false.obs;

  @override
  void dispose() {
    profileIdController.dispose();
    nameController.dispose();
    levelController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  void _resetForm() {
    editingSkill.value = null;
    nameController.clear();
    levelController.clear();
    categoryController.text = 'General';
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
      category: categoryController.text,
      sortOrder: editingSkill.value?.sortOrder ?? controller.skills.length,
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
                      title: 'skills'.tr,
                      subtitle: 'skill_form_subtitle'.tr,
                      headerTrailing: OutlinedButton.icon(
                        onPressed: _loadList,
                        icon: const Icon(Icons.download_outlined),
                        label: Text('load_list'.tr),
                      ),
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
                                controller: profileIdController,
                                decoration: InputDecoration(
                                  labelText: 'profile_id'.tr,
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                ),
                                keyboardType: TextInputType.number,
                                validator: FormValidators.numeric,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'skill_name_label'.tr,
                                  prefixIcon: const Icon(Icons.lightbulb_outline),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: levelController,
                                decoration: InputDecoration(
                                  labelText: 'level_label'.tr,
                                  prefixIcon: const Icon(Icons.auto_graph),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: categoryController,
                                decoration: InputDecoration(
                                  labelText: 'category'.tr,
                                  prefixIcon: const Icon(Icons.category_outlined),
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
                                  Obx(() => ElevatedButton.icon(
                                        onPressed:
                                            isFormValid.value ? _submit : null,
                                        icon: Icon(editingSkill.value == null
                                            ? Icons.save_outlined
                                            : Icons.check_circle_outline),
                                        label: Text(
                                          editingSkill.value == null
                                              ? 'save'.tr
                                              : 'update'.tr,
                                        ),
                                      )),
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
                      title: 'skills'.tr,
                      subtitle: 'skill_list_subtitle'.tr,
                      child: Obx(() {
                        final skills = controller.skills;

                        if (skills.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('no_skills'.tr),
                          );
                        }

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: skills
                              .map(
                                (skill) => SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth / 2) - 20
                                      : constraints.maxWidth,
                                  child: _SkillCard(
                                    skill: skill,
                                    onEdit: () {
                                      editingSkill.value = skill;
                                      profileIdController.text =
                                          skill.profileId.toString();
                                      nameController.text = skill.name;
                                      levelController.text = skill.level;
                                      categoryController.text = skill.category;
                                      _updateFormValidity();
                                    },
                                    onDelete: () async {
                                      if (skill.id != null) {
                                        await controller.delete(skill.id!);
                                      }
                                    },
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
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.skill,
    required this.onEdit,
    required this.onDelete,
  });

  final Skill skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    skill.name.isNotEmpty ? skill.name[0].toUpperCase() : '?',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'level_label'.tr}: ${skill.level}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (skill.category.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(skill.category),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'edit'.tr,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      tooltip: 'delete'.tr,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
