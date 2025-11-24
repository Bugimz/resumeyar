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

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final BackupService _backupService = BackupService(
    resumeProfileRepository: ResumeProfileRepository(),
    workExperienceRepository: WorkExperienceRepository(),
    educationRepository: EducationRepository(),
    skillRepository: SkillRepository(),
    projectRepository: ProjectRepository(),
  );

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
          ],
        ),
      ),
    );
  }
}
