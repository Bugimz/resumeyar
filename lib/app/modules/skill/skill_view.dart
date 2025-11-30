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
                            child: TextFormField(
                              controller: levelController,
                              decoration:
                                  InputDecoration(labelText: 'level_label'.tr),
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
                                      profileIdController.text =
                                          skill.profileId.toString();
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
            ),
          );
        },
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
