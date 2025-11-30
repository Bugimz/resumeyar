import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import '../../data/repositories/education_repository.dart';
import '../../data/repositories/interest_repository.dart';
import '../../data/repositories/language_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/resume_profile_repository.dart';
import '../../data/repositories/certification_repository.dart';
import '../../data/repositories/skill_repository.dart';
import '../../data/repositories/work_experience_repository.dart';
import '../../services/backup_service.dart';
import '../../services/billing_service.dart';
import '../../services/premium_service.dart';
import '../../services/settings_service.dart';
import '../../utils/resume_sections.dart';

class SettingsView extends StatefulWidget {
  SettingsView({super.key});

  final BackupService _backupService = BackupService(
    resumeProfileRepository: ResumeProfileRepository(),
    workExperienceRepository: WorkExperienceRepository(),
    educationRepository: EducationRepository(),
    certificationRepository: CertificationRepository(),
    languageRepository: LanguageRepository(),
    interestRepository: InterestRepository(),
    skillRepository: SkillRepository(),
    projectRepository: ProjectRepository(),
  );

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsService _settingsService = SettingsService();
  final PremiumService _premiumService = Get.find<PremiumService>();

  List<ResumeSection> _sectionOrder = ResumeSection.values.toList();
  Set<ResumeSection> _hiddenSections = <ResumeSection>{};
  bool _showGpa = true;
  PdfPageSize _pageSize = PdfPageSize.a4;
  PdfThemeMode _pdfTheme = PdfThemeMode.light;
  bool _isLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _backupError;
  String? _lastBackupLocation;
  DateTime? _lastBackupTime;
  BackupDestination _backupDestination = BackupDestination.local;

  bool get _isPremium => _premiumService.isPremium.value;

  Future<bool> _requirePremium() async {
    if (_isPremium) return true;

    await Get.dialog(
      AlertDialog(
        title: Text('premium_required'.tr),
        content: Text('premium_required_message'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await _premiumService.buyPremium();
              Get.back();
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.workspace_premium),
            label: Text('upgrade_now'.tr),
          ),
        ],
      ),
    );

    return _isPremium;
  }

  Future<void> _saveBackup() async {
    if (!await _requirePremium()) return;
    final confirmed = await _confirmAction(
      title: 'confirm_backup'.tr,
      message: 'confirm_backup_message'.tr,
    );
    if (!confirmed) return;

    if (_backupDestination == BackupDestination.cloud) {
      Get.snackbar('info'.tr, 'cloud_backup_not_available'.tr);
      return;
    }

    setState(() {
      _isBackingUp = true;
      _backupError = null;
    });
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

      final backupContent = await widget._backupService.exportToJson();
      final file = File(backupPath);
      await file.writeAsString(backupContent);

      await _settingsService.saveLastBackup(
        path: backupPath,
        destination: _backupDestination,
      );
      setState(() {
        _lastBackupLocation = backupPath;
        _lastBackupTime = DateTime.now();
      });

      Get.snackbar('success'.tr, 'backup_saved'.trParams({'path': backupPath}));
    } catch (e) {
      setState(() => _backupError = '$e');
      Get.snackbar('error'.tr, 'backup_failed'.trParams({'error': '$e'}));
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    if (!await _requirePremium()) return;
    final confirmed = await _confirmAction(
      title: 'confirm_restore'.tr,
      message: 'confirm_restore_message'.tr,
    );
    if (!confirmed) return;

    if (_backupDestination == BackupDestination.cloud) {
      Get.snackbar('info'.tr, 'cloud_restore_not_available'.tr);
      return;
    }

    setState(() {
      _isRestoring = true;
      _backupError = null;
    });
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
      await widget._backupService.importFromJson(content);

      Get.snackbar('success'.tr, 'backup_restored'.tr);
    } on FormatException catch (e) {
      Get.snackbar('error'.tr, 'invalid_backup_format'.trParams({'error': '$e'}));
    } catch (e) {
      setState(() => _backupError = '$e');
      Get.snackbar('error'.tr, 'backup_restore_failed'.trParams({'error': '$e'}));
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  Future<bool> _confirmAction({required String title, required String message}) {
    return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('cancel'.tr),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('confirm'.tr),
              ),
            ],
          ),
        )
            .then((value) => value ?? false);
  }

  @override
  void initState() {
    super.initState();
    _loadSectionOrder();
  }

  Future<void> _loadSectionOrder() async {
    final order = await _settingsService.loadResumeSectionOrder();
    final hidden = await _settingsService.loadHiddenSections();
    final showGpa = await _settingsService.loadGpaVisibility();
    final pageFormat = await _settingsService.loadPageFormat();
    final pdfTheme = await _settingsService.loadPdfTheme();
    final lastBackup = await _settingsService.loadLastBackup();
    if (!mounted) return;
    setState(() {
      _sectionOrder = order;
      _hiddenSections = hidden;
      _showGpa = showGpa;
      _pdfTheme = pdfTheme;
      _pageSize = pageFormat == PdfPageFormat.letter
          ? PdfPageSize.letter
          : PdfPageSize.a4;
      _backupDestination = lastBackup.destination;
      _lastBackupLocation = lastBackup.path;
      _lastBackupTime = lastBackup.time;
      _isLoading = false;
    });
  }

  String _buildLastBackupLabel(BuildContext context) {
    if (_lastBackupTime == null || _lastBackupLocation == null) {
      return 'no_backup_yet'.tr;
    }

    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final timeFormat = DateFormat.Hm(Localizations.localeOf(context).languageCode);
    final formattedTime =
        '${dateFormat.format(_lastBackupTime!)} • ${timeFormat.format(_lastBackupTime!)}';
    final locationLabel = _backupDestination == BackupDestination.cloud
        ? 'cloud_storage'.tr
        : _lastBackupLocation!;

    return '${'last_backup'.tr}: $formattedTime (${locationLabel})';
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

  Future<void> _toggleSectionVisibility(
    ResumeSection section,
    bool enabled,
  ) async {
    setState(() {
      if (enabled) {
        _hiddenSections.remove(section);
      } else {
        _hiddenSections.add(section);
      }
    });

    await _settingsService.saveHiddenSections(_hiddenSections);
  }

  Future<void> _updateGpaVisibility(bool value) async {
    setState(() => _showGpa = value);
    await _settingsService.saveGpaVisibility(value);
  }

  Future<void> _updatePageSize(PdfPageSize size) async {
    setState(() => _pageSize = size);
    await _settingsService.savePageFormat(size);
  }

  Future<void> _updatePdfTheme(PdfThemeMode mode) async {
    setState(() => _pdfTheme = mode);
    await _settingsService.savePdfTheme(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        return Obx(() {
          final isPremium = _premiumService.isPremium.value;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SettingsHero(
                    isPremium: isPremium,
                    onUpgrade: _premiumService.buyPremium,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'save_backup'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'premium_backup_message'.tr,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(builder: (context, innerConstraints) {
                            final buttonWidth = innerConstraints.maxWidth > 500
                                ? (innerConstraints.maxWidth - 12) / 2
                                : innerConstraints.maxWidth;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: buttonWidth,
                                  child: FilledButton.icon(
                                    onPressed: _saveBackup,
                                    icon: const Icon(Icons.save_alt),
                                    label: Text('save_backup'.tr),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(52),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: buttonWidth,
                                  child: FilledButton.icon(
                                    onPressed: _restoreBackup,
                                    icon: const Icon(Icons.restore),
                                    label: Text('restore_backup'.tr),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(52),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'resume_section_order'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'drag_to_reorder_sections'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Card(
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                ],
              ),
            ),
          );
        });
      }),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero(
      {required this.isPremium, required this.onUpgrade, required this.isWide});

  final bool isPremium;
  final Future<void> Function() onUpgrade;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPremium ? Icons.verified : Icons.workspace_premium,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isPremium ? 'premium_active_title'.tr : 'premium_title'.tr,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isPremium ? 'hero_premium_body'.tr : 'premium_backup_message'.tr,
          style:
              theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
        ),
        const SizedBox(height: 12),
        if (!isPremium)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onUpgrade,
            child: Text('upgrade_now'.tr),
          )
        else
          Text(
            'premium_active_message'.tr,
            style:
                theme.textTheme.labelMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
      ],
    );

    final badge = Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: const Icon(Icons.security_outlined, color: Colors.white),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: column),
                const SizedBox(width: 12),
                badge,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                column,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: badge),
              ],
            ),
    );
  }
}
