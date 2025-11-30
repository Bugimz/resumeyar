import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

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
                              controller: companyController,
                              decoration:
                                  InputDecoration(labelText: 'company_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: positionController,
                              decoration:
                                  InputDecoration(labelText: 'position_label'.tr),
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
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
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
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
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
                                  labelText: 'description_label'.tr),
                              validator: FormValidators.requiredField,
                              maxLines: 3,
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
                                        editingExperience.value == null
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
                      'work_experiences_title'.tr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
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
                              title: Text(
                                  '${experience.company} • ${experience.position}'),
                              subtitle: Text(
                                  '${experience.startDate} - ${experience.endDate}\n${experience.description}'),
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
            ),
          );
        },
      ),
    );
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
    if (tags.isEmpty) {
      return const Text('No tech tags added');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => Chip(label: Text(tag))).toList(),
    );
  }
}
