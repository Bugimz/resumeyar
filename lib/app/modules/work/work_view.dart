import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../data/models/work_experience.dart';
import '../../utils/validators.dart';
import '../../utils/widgets/section_card.dart';
import 'work_controller.dart';

class WorkView extends GetView<WorkController> {
  WorkView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController =
      TextEditingController(text: '1');
  final TextEditingController companyController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController achievementsController = TextEditingController();
  final TextEditingController techTagsController = TextEditingController();
  final TextEditingController metricController = TextEditingController();
  final Rxn<WorkExperience> editingExperience = Rxn<WorkExperience>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingExperience.value = null;
    companyController.clear();
    positionController.clear();
    startDateController.clear();
    endDateController.clear();
    descriptionController.clear();
    achievementsController.clear();
    techTagsController.clear();
    metricController.clear();
    isFormValid.value = false;
  }

  String _formatDate(DateTime date) {
    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1300, 1),
      lastDate: Jalali(1500, 12),
    );

    if (picked != null) {
      controller.text = _formatDate(picked.toDateTime());
      _updateFormValidity();
    }
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

  List<String> _parseAchievements() {
    return achievementsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty)
        .toList();
  }

  List<String> _parseTags() {
    return techTagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty)
        .toList();
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
      achievements: _parseAchievements(),
      techTags: _parseTags(),
      metric: metricController.text.trim().isEmpty
          ? null
          : metricController.text.trim(),
    );

    if (editingExperience.value == null) {
      await controller.save(experience);
    } else {
      await controller.updateWork(experience);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('work_experience'.tr),
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
                      title: 'work_experience'.tr,
                      subtitle: 'work_form_subtitle'.tr,
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
                                controller: companyController,
                                decoration: InputDecoration(
                                  labelText: 'company_label'.tr,
                                  prefixIcon: const Icon(Icons.business_center),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: positionController,
                                decoration: InputDecoration(
                                  labelText: 'position_label'.tr,
                                  prefixIcon: const Icon(Icons.work_outline),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: startDateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'start_date'.tr,
                                  prefixIcon:
                                      const Icon(Icons.calendar_today_outlined),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.event),
                                    onPressed: () => _pickDate(
                                      context,
                                      startDateController,
                                    ),
                                  ),
                                ),
                                validator: FormValidators.date,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: endDateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'end_date'.tr,
                                  prefixIcon:
                                      const Icon(Icons.calendar_today_outlined),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.event),
                                    onPressed: () => _pickDate(
                                      context,
                                      endDateController,
                                    ),
                                  ),
                                ),
                                validator: (_) => FormValidators.startBeforeEnd(
                                  start: startDateController.text,
                                  end: endDateController.text,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                    labelText: 'description_label'.tr,
                                    prefixIcon:
                                        const Icon(Icons.description_outlined)),
                                validator: FormValidators.requiredField,
                                maxLines: 3,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: achievementsController,
                                decoration: InputDecoration(
                                  labelText: 'achievements_label'.tr,
                                  hintText: 'bullet_points_hint'.tr,
                                  prefixIcon: const Icon(Icons.emoji_events),
                                ),
                                maxLines: 3,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: techTagsController,
                                decoration: InputDecoration(
                                  labelText: 'tech_stack_label'.tr,
                                  hintText: 'comma_separated_hint'.tr,
                                  prefixIcon: const Icon(Icons.memory_outlined),
                                ),
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: metricController,
                                decoration: InputDecoration(
                                  labelText: 'metric_label'.tr,
                                  prefixIcon: const Icon(Icons.trending_up),
                                ),
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
                                        icon: Icon(editingExperience.value == null
                                            ? Icons.save_outlined
                                            : Icons.check_circle_outline),
                                        label: Text(
                                          editingExperience.value == null
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
                      title: 'work_experiences_title'.tr,
                      subtitle: 'work_list_subtitle'.tr,
                      child: Obx(() {
                        final works = controller.works;

                        if (works.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('no_work_experiences'.tr),
                          );
                        }

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: works
                              .map(
                                (experience) => SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth / 2) - 20
                                      : constraints.maxWidth,
                                  child: _ExperienceCard(
                                    experience: experience,
                                    isWide: isWide,
                                    onEdit: () {
                                      editingExperience.value = experience;
                                      profileIdController.text =
                                          experience.profileId.toString();
                                      companyController.text =
                                          experience.company;
                                      positionController.text =
                                          experience.position;
                                      startDateController.text =
                                          experience.startDate;
                                      endDateController.text =
                                          experience.endDate;
                                      descriptionController.text =
                                          experience.description;
                                      achievementsController.text =
                                          experience.achievements.join('\n');
                                      techTagsController.text =
                                          experience.techTags.join(', ');
                                      metricController.text =
                                          experience.metric ?? '';
                                      _updateFormValidity();
                                    },
                                    onDelete: () async {
                                      if (experience.id != null) {
                                        await controller.delete(experience.id!);
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

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.experience,
    required this.isWide,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkExperience experience;
  final bool isWide;
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
                Icon(Icons.business_center,
                    color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${experience.company} • ${experience.position}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${experience.startDate} - ${experience.endDate}',
                        style: theme.textTheme.bodyMedium,
                      ),
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
            const SizedBox(height: 8),
            Text(
              experience.description,
              style: theme.textTheme.bodyMedium,
            ),
            if (experience.metric != null && experience.metric!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(experience.metric!),
                avatar: const Icon(Icons.trending_up, size: 16),
              ),
            ],
            if (experience.achievements.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'achievements_label'.tr,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _buildAchievementsSection(experience.achievements, isWide),
            ],
            if (experience.techTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'tech_stack_label'.tr,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _buildTechTags(experience.techTags),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildAchievementsSection(List<String> achievements, bool isWide) {
  final chips = achievements
      .map((achievement) => Chip(label: Text(achievement)))
      .toList();

  if (isWide) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: achievements
        .map(
          (achievement) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(achievement)),
              ],
            ),
          ),
        )
        .toList(),
  );
}

Widget _buildTechTags(List<String> tags) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: tags.map((tag) => Chip(label: Text(tag))).toList(),
  );
}
