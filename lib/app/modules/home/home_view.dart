import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../../services/pdf_service.dart';
import '../../theme/theme_controller.dart';
import '../../data/repositories/education_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/resume_profile_repository.dart';
import '../../data/repositories/skill_repository.dart';
import '../../data/repositories/work_experience_repository.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final PdfService _pdfService = PdfService(
    resumeProfileRepository: ResumeProfileRepository(),
    workExperienceRepository: WorkExperienceRepository(),
    educationRepository: EducationRepository(),
    skillRepository: SkillRepository(),
    projectRepository: ProjectRepository(),
  );

  final ThemeController _themeController = Get.find<ThemeController>();
  final Rx<Locale> _locale = Rx<Locale>(Get.locale ?? const Locale('en', 'US'));
  final Rx<ResumeTemplate> _selectedTemplate = ResumeTemplate.minimal.obs;

  final List<Locale> _supportedLocales = const [
    Locale('en', 'US'),
    Locale('fa', 'IR'),
  ];

  Future<void> _downloadPdf(bool isRtl) async {
    try {
      await _pdfService.shareResumePdf(
        template: _selectedTemplate.value,
        isRtl: isRtl,
      );
      Get.snackbar('success'.tr, 'resume_pdf_generated'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_generate_pdf'.trParams({'error': '$e'}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRtl = _locale.value.languageCode == 'fa';

      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text('app_title'.tr),
            actions: [
              DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: _locale.value,
                  icon: const Icon(Icons.language),
                  onChanged: (locale) {
                    if (locale != null) {
                      _locale.value = locale;
                      Get.updateLocale(locale);
                    }
                  },
                  items: _supportedLocales
                      .map(
                        (locale) => DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(
                            locale.languageCode == 'fa'
                                ? 'persian'.tr
                                : 'english'.tr,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Obx(
                () => IconButton(
                  icon: Icon(
                    _themeController.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  onPressed: _themeController.toggleTheme,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<ResumeTemplate>(
                value: _selectedTemplate.value,
                decoration: InputDecoration(labelText: 'template'.tr),
                items: ResumeTemplate.values
                    .map(
                      (template) => DropdownMenuItem<ResumeTemplate>(
                        value: template,
                        child: Text(
                          template == ResumeTemplate.minimal
                              ? 'template_minimal'.tr
                              : 'template_modern'.tr,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (template) {
                  if (template != null) {
                    _selectedTemplate.value = template;
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _downloadPdf(isRtl),
                icon: const Icon(Icons.picture_as_pdf),
                label: Text('download_pdf'.tr),
              ),
              const SizedBox(height: 16),
              const _NavigationTile(title: 'profile', route: Routes.profile),
              const _NavigationTile(
                  title: 'work_experience', route: Routes.work),
              const _NavigationTile(title: 'education', route: Routes.education),
              const _NavigationTile(title: 'skills', route: Routes.skills),
              const _NavigationTile(title: 'projects', route: Routes.projects),
              const _NavigationTile(title: 'settings', route: Routes.settings),
            ],
          ),
        ),
      );
    });
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({required this.title, required this.route});

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title.tr),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(route),
      ),
    );
  }
}
