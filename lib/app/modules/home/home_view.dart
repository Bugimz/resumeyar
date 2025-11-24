import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../../services/pdf_service.dart';
import '../../services/premium_service.dart';
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
  final PremiumService _premiumService = Get.find<PremiumService>();
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
      final isPremium = _premiumService.isPremium.value;

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
              _GoldBanner(
                onUpgrade: _premiumService.buyPremium,
                isPremium: isPremium,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ResumeTemplate>(
                value: _selectedTemplate.value,
                decoration: InputDecoration(labelText: 'template'.tr),
                items: ResumeTemplate.values
                    .map(
                      (template) => DropdownMenuItem<ResumeTemplate>(
                        value: template,
                        enabled: isPremium || template != ResumeTemplate.elegant,
                        child: Text(
                          switch (template) {
                            ResumeTemplate.minimal => 'template_minimal'.tr,
                            ResumeTemplate.modern => 'template_modern'.tr,
                            ResumeTemplate.elegant => 'template_elegant'.tr,
                          },
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (template) {
                  if (template == null) return;
                  if (template == ResumeTemplate.elegant && !isPremium) {
                    Get.snackbar('premium_required'.tr, 'premium_template'.tr);
                    return;
                  }
                  _selectedTemplate.value = template;
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

class _GoldBanner extends StatelessWidget {
  const _GoldBanner({required this.onUpgrade, required this.isPremium});

  final Future<void> Function() onUpgrade;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    if (isPremium) {
      return Card(
        color: Colors.amber.shade50,
        child: ListTile(
          leading: const Icon(Icons.workspace_premium, color: Colors.amber),
          title: Text('premium_active_title'.tr),
          subtitle: Text('premium_active_message'.tr),
        ),
      );
    }

    return Card(
      color: Colors.amber.shade50,
      child: ListTile(
        leading: const Icon(Icons.workspace_premium, color: Colors.amber),
        title: Text('premium_title'.tr),
        subtitle: Text('premium_subtitle'.tr),
        trailing: ElevatedButton(
          onPressed: onUpgrade,
          child: Text('upgrade_now'.tr),
        ),
      ),
    );
  }
}
