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
  final Rxn<Skill> editingSkill = Rxn<Skill>();
  final Rx<SkillCategory> selectedCategory = SkillCategory.language.obs;
  final RxString levelMode = 'numeric'.obs;
  final RxInt numericLevel = 3.obs;
  final Rxn<SkillProficiency> selectedProficiency = Rxn<SkillProficiency>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingSkill.value = null;
    nameController.clear();
    selectedCategory.value = SkillCategory.language;
    levelMode.value = 'numeric';
    numericLevel.value = 3;
    selectedProficiency.value = null;
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
      category: selectedCategory.value,
      levelValue: levelMode.value == 'numeric' ? numericLevel.value : null,
      proficiency: levelMode.value == 'proficiency' ? selectedProficiency.value : null,
      sortOrder: editingSkill.value?.sortOrder ?? -1,
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
    final theme = Theme.of(context);
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
                              controller: nameController,
                              decoration:
                                  InputDecoration(labelText: 'skill_name_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Obx(
                              () => DropdownButtonFormField<SkillCategory>(
                                value: selectedCategory.value,
                                decoration:
                                    InputDecoration(labelText: 'skill_category_label'.tr),
                                items: SkillCategory.values
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text('category_${category.name}'.tr),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    selectedCategory.value = value;
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'level_label'.tr,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      ChoiceChip(
                                        label: Text('level_numeric'.tr),
                                        selected: levelMode.value == 'numeric',
                                        onSelected: (_) {
                                          levelMode.value = 'numeric';
                                          selectedProficiency.value = null;
                                          _updateFormValidity();
                                        },
                                      ),
                                      ChoiceChip(
                                        label: Text('level_proficiency'.tr),
                                        selected: levelMode.value == 'proficiency',
                                        onSelected: (_) {
                                          levelMode.value = 'proficiency';
                                          _updateFormValidity();
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (levelMode.value == 'numeric')
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Slider(
                                          value: numericLevel.value.toDouble(),
                                          min: 1,
                                          max: 5,
                                          divisions: 4,
                                          label: numericLevel.value.toString(),
                                          onChanged: (value) {
                                            numericLevel.value = value.round();
                                            _updateFormValidity();
                                          },
                                        ),
                                        Text('level_value'.trParams(
                                            {'value': numericLevel.value.toString()})),
                                      ],
                                    )
                                  else
                                    DropdownButtonFormField<SkillProficiency>(
                                      value: selectedProficiency.value,
                                      decoration: InputDecoration(
                                          labelText: 'level_proficiency'.tr),
                                      items: SkillProficiency.values
                                          .map(
                                            (proficiency) => DropdownMenuItem(
                                              value: proficiency,
                                              child: Text(
                                                'proficiency_${proficiency.name}'.tr,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        selectedProficiency.value = value;
                                        _updateFormValidity();
                                      },
                                      validator: (value) {
                                        if (levelMode.value == 'proficiency' && value == null) {
                                          return 'required_field'.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                ],
                              ),
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
                                        editingSkill.value == null
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
                      'skills'.tr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final skills = controller.skills;

                      if (skills.isEmpty) {
                        return Text('no_skills'.tr);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: SkillCategory.values.map((category) {
                          final categorySkills = skills
                              .where((skill) => skill.category == category)
                              .toList()
                            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                          if (categorySkills.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final sectionContent = Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: categorySkills
                                  .map((skill) => _SkillChip(
                                        skill: skill,
                                        onEdit: () {
                                          editingSkill.value = skill;
                                          profileIdController.text =
                                              skill.profileId.toString();
                                          nameController.text = skill.name;
                                          selectedCategory.value = skill.category;
                                          if (skill.levelValue != null) {
                                            levelMode.value = 'numeric';
                                            numericLevel.value = skill.levelValue!;
                                          } else {
                                            levelMode.value = 'proficiency';
                                            selectedProficiency.value = skill.proficiency;
                                          }
                                          _updateFormValidity();
                                        },
                                        onDelete: () async {
                                          if (skill.id != null) {
                                            await controller.delete(skill.id!);
                                          }
                                        },
                                        onReorder: (dragged) async {
                                          await controller.reorderWithinCategory(
                                            dragged: dragged,
                                            target: skill,
                                          );
                                        },
                                      ))
                                  .toList(),
                            ),
                          );

                          final title = Text(
                            'category_${category.name}'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          );

                          if (!isWide) {
                            return Card(
                              child: ExpansionTile(
                                title: title,
                                children: [sectionContent],
                              ),
                            );
                          }

                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: title,
                                ),
                                sectionContent,
                              ],
                            ),
                          );
                        }).toList(),
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

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.skill,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  final Skill skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<Skill> onReorder;

  Color _levelColor(BuildContext context) {
    switch (skill.proficiency) {
      case SkillProficiency.beginner:
        return Colors.orange.shade200;
      case SkillProficiency.intermediate:
        return Colors.blue.shade200;
      case SkillProficiency.expert:
        return Colors.green.shade200;
      case null:
        final progress = skill.levelProgress ?? 0;
        return Color.lerp(Colors.orange, Colors.green, progress) ??
            Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelLabel = skill.displayLevel;
    final progress = skill.levelProgress;

    return LongPressDraggable<Skill>(
      data: skill,
      feedback: Material(
        color: Colors.transparent,
        child: _ChipContent(
          skill: skill,
          levelLabel: levelLabel,
          progress: progress,
          isDragging: true,
          levelColor: _levelColor(context),
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
      child: DragTarget<Skill>(
        onWillAccept: (dragged) =>
            dragged?.id != skill.id && dragged?.category == skill.category,
        onAccept: onReorder,
        builder: (context, candidate, rejected) {
          return _ChipContent(
            skill: skill,
            levelLabel: levelLabel,
            progress: progress,
            isHighlighted: candidate.isNotEmpty,
            levelColor: _levelColor(context),
            onEdit: onEdit,
            onDelete: onDelete,
          );
        },
      ),
    );
  }
}

class _ChipContent extends StatelessWidget {
  const _ChipContent({
    required this.skill,
    required this.levelLabel,
    required this.progress,
    required this.levelColor,
    this.isHighlighted = false,
    this.isDragging = false,
    required this.onEdit,
    required this.onDelete,
  });

  final Skill skill;
  final String levelLabel;
  final double? progress;
  final Color levelColor;
  final bool isHighlighted;
  final bool isDragging;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final chipColor = isHighlighted
        ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
        : Theme.of(context).chipTheme.backgroundColor ?? Colors.grey.shade200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade600),
          Text(
            skill.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (levelLabel.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                levelLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          if (progress != null)
            SizedBox(
              width: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'edit'.tr,
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                tooltip: 'delete'.tr,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
