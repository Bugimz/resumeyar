import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/education_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/resume_profile_repository.dart';
import '../../data/repositories/skill_repository.dart';
import '../../data/repositories/work_experience_repository.dart';
import '../../services/backup_service.dart';
import '../../services/settings_service.dart';
import '../../utils/resume_sections.dart';

class SettingsView extends StatefulWidget {
  SettingsView({super.key});

  final BackupService _backupService = BackupService(
    resumeProfileRepository: ResumeProfileRepository(),
    workExperienceRepository: WorkExperienceRepository(),
    educationRepository: EducationRepository(),
    skillRepository: SkillRepository(),
    projectRepository: ProjectRepository(),
  );

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsService _settingsService = SettingsService();

  List<ResumeSection> _sectionOrder = ResumeSection.values.toList();
  bool _isLoading = true;

  Future<void> _saveBackup() async {
    try {
      final backupPath = await FilePicker.platform.saveFile(
        dialogTitle: 'select_backup_path'.tr,
        fileName: 'resume_backup.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );

      if (backupPath == null) {
        return;
      }

      final backupContent = await _backupService.exportToJson();
      final file = File(backupPath);
      await file.writeAsString(backupContent);

      Get.snackbar('success'.tr, 'backup_saved'.trParams({'path': backupPath}));
    } catch (e) {
      Get.snackbar('error'.tr, 'backup_failed'.trParams({'error': '$e'}));
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        dialogTitle: 'select_backup_file'.tr,
      );

      final filePath = result?.files.single.path;
      if (filePath == null) {
        return;
      }

      final content = await File(filePath).readAsString();
      await _backupService.importFromJson(content);

      Get.snackbar('success'.tr, 'backup_restored'.tr);
    } on FormatException catch (e) {
      Get.snackbar('error'.tr, 'invalid_backup_format'.trParams({'error': '$e'}));
    } catch (e) {
      Get.snackbar('error'.tr, 'backup_restore_failed'.trParams({'error': '$e'}));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSectionOrder();
  }

  Future<void> _loadSectionOrder() async {
    final order = await _settingsService.loadResumeSectionOrder();
    if (!mounted) return;
    setState(() {
      _sectionOrder = order;
      _isLoading = false;
    });
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final section = _sectionOrder.removeAt(oldIndex);
      _sectionOrder.insert(newIndex, section);
    });

    await _settingsService.saveResumeSectionOrder(_sectionOrder);
    Get.snackbar('success'.tr, 'sections_order_saved'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _saveBackup,
              icon: const Icon(Icons.save_alt),
              label: Text('save_backup'.tr),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _restoreBackup,
              icon: const Icon(Icons.restore),
              label: Text('restore_backup'.tr),
            ),
            const SizedBox(height: 24),
            Text(
              'resume_section_order'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'drag_to_reorder_sections'.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: Card(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _sectionOrder.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final section = _sectionOrder[index];
                      return ListTile(
                        key: ValueKey(section.name),
                        leading: const Icon(Icons.drag_indicator),
                        title: Text(section.localizedLabel),
                        trailing: const Icon(Icons.more_vert),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
