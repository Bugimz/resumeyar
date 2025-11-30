import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../routes/app_pages.dart';
import '../../services/pdf_service.dart';
import '../../services/premium_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';
import '../../data/models/resume_profile.dart';
import '../../data/models/work_experience.dart';
import '../../data/models/project.dart';
import '../../data/models/education.dart';
import '../../data/models/certification.dart';
import '../../data/models/language.dart';
import '../../data/models/interest.dart';
import '../../data/models/skill.dart';
import '../../data/repositories/resume_profile_repository.dart';
import '../../data/repositories/work_experience_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/education_repository.dart';
import '../../data/repositories/certification_repository.dart';
import '../../data/repositories/language_repository.dart';
import '../../data/repositories/interest_repository.dart';
import '../../data/repositories/skill_repository.dart';

class ReviewView extends StatefulWidget {
  const ReviewView({super.key});

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  final ResumeProfileRepository _profileRepository = ResumeProfileRepository();
  final WorkExperienceRepository _workRepository = WorkExperienceRepository();
  final ProjectRepository _projectRepository = ProjectRepository();
  final EducationRepository _educationRepository = EducationRepository();
  final CertificationRepository _certificationRepository = CertificationRepository();
  final LanguageRepository _languageRepository = LanguageRepository();
  final InterestRepository _interestRepository = InterestRepository();
  final SkillRepository _skillRepository = SkillRepository();

  late final PdfService _pdfService = PdfService(
    resumeProfileRepository: _profileRepository,
    workExperienceRepository: _workRepository,
    educationRepository: _educationRepository,
    certificationRepository: _certificationRepository,
    languageRepository: _languageRepository,
    interestRepository: _interestRepository,
    skillRepository: _skillRepository,
    projectRepository: _projectRepository,
  );

  final ThemeController _themeController = Get.find<ThemeController>();
  final PremiumService _premiumService = Get.find<PremiumService>();

  bool _isLoading = true;
  Locale _locale = Get.locale ?? const Locale('en', 'US');
  ResumeTemplate _selectedTemplate = ResumeTemplate.minimal;
  GlobalKey<PdfPreviewState> _previewKey = GlobalKey<PdfPreviewState>();

  List<ResumeProfile> _profiles = [];
  List<WorkExperience> _workExperiences = [];
  List<Project> _projects = [];
  List<Education> _educations = [];
  List<Certification> _certifications = [];
  List<Language> _languages = [];
  List<Interest> _interests = [];
  List<Skill> _skills = [];
  List<_ReviewIssue> _issues = [];

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  bool get _isRtl => _locale.languageCode == 'fa';

  Future<void> _loadReview() async {
    setState(() => _isLoading = true);

    final profiles = await _profileRepository.getAll();
    final work = await _workRepository.getAll();
    final projects = await _projectRepository.getAll();
    final educations = await _educationRepository.getAll();
    final certifications = await _certificationRepository.getAll();
    final languages = await _languageRepository.getAll();
    final interests = await _interestRepository.getAll();
    final skills = await _skillRepository.getAll();

    final List<_ReviewIssue> issues = [];
    final ResumeProfile? primaryProfile = profiles.isNotEmpty ? profiles.first : null;

    if (primaryProfile == null) {
      issues.add(
        _ReviewIssue(
          title: 'issue_no_profile'.tr,
          description: 'issue_no_profile_hint'.tr,
          route: Routes.profile,
          icon: Icons.person_outline,
        ),
      );
    } else if (primaryProfile.summary.trim().isEmpty) {
      issues.add(
        _ReviewIssue(
          title: 'issue_empty_summary'.tr,
          description: 'issue_empty_summary_hint'.tr,
          route: Routes.profile,
          icon: Icons.short_text,
        ),
      );
    }

    if (work.isEmpty) {
      issues.add(
        _ReviewIssue(
          title: 'issue_no_work'.tr,
          description: 'issue_no_work_hint'.tr,
          route: Routes.work,
          icon: Icons.badge_outlined,
        ),
      );
    }

    for (final experience in work) {
      if (experience.metric == null || experience.metric!.trim().isEmpty) {
        issues.add(
          _ReviewIssue(
            title: 'issue_no_metric'.trParams({'item': experience.company}),
            description: 'issue_no_metric_hint'.tr,
            route: Routes.work,
            icon: Icons.query_stats_outlined,
          ),
        );
      }
    }

    for (final project in projects) {
      if (project.responsibilities.isEmpty || project.description.trim().isEmpty) {
        issues.add(
          _ReviewIssue(
            title: 'issue_no_responsibilities'.trParams({'item': project.title}),
            description: 'issue_no_responsibilities_hint'.tr,
            route: Routes.projects,
            icon: Icons.checklist_rtl,
          ),
        );
      }
    }

    setState(() {
      _profiles = profiles;
      _workExperiences = work;
      _projects = projects;
      _educations = educations;
      _certifications = certifications;
      _languages = languages;
      _interests = interests;
      _skills = skills;
      _issues = issues;
      _isLoading = false;
    });
  }

  void _onTemplateSelected(ResumeTemplate template, bool isPremium) {
    if (template == ResumeTemplate.elegant && !isPremium) {
      Get.snackbar('premium_required'.tr, 'premium_template'.tr);
      return;
    }

    setState(() {
      _selectedTemplate = template;
      _previewKey = GlobalKey<PdfPreviewState>();
    });
  }

  List<_SectionReview> _buildSections() {
    List<_ReviewIssue> issuesForRoute(String route) =>
        _issues.where((issue) => issue.route == route).toList();

    return [
      _SectionReview(
        titleKey: 'profile',
        route: Routes.profile,
        icon: Icons.person_outline,
        itemCount: _profiles.length,
        issueCount: issuesForRoute(Routes.profile).length,
      ),
      _SectionReview(
        titleKey: 'work_experience',
        route: Routes.work,
        icon: Icons.badge_outlined,
        itemCount: _workExperiences.length,
        issueCount: issuesForRoute(Routes.work).length,
      ),
      _SectionReview(
        titleKey: 'education',
        route: Routes.education,
        icon: Icons.school_outlined,
        itemCount: _educations.length,
        issueCount: issuesForRoute(Routes.education).length,
      ),
      _SectionReview(
        titleKey: 'certifications',
        route: Routes.certifications,
        icon: Icons.workspace_premium_outlined,
        itemCount: _certifications.length,
        issueCount: issuesForRoute(Routes.certifications).length,
      ),
      _SectionReview(
        titleKey: 'languages',
        route: Routes.languages,
        icon: Icons.translate,
        itemCount: _languages.length,
        issueCount: issuesForRoute(Routes.languages).length,
      ),
      _SectionReview(
        titleKey: 'skills',
        route: Routes.skills,
        icon: Icons.star_border,
        itemCount: _skills.length,
        issueCount: issuesForRoute(Routes.skills).length,
      ),
      _SectionReview(
        titleKey: 'projects',
        route: Routes.projects,
        icon: Icons.widgets_outlined,
        itemCount: _projects.length,
        issueCount: issuesForRoute(Routes.projects).length,
      ),
      _SectionReview(
        titleKey: 'interests',
        route: Routes.interests,
        icon: Icons.favorite_border,
        itemCount: _interests.length,
        issueCount: issuesForRoute(Routes.interests).length,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPremium = _premiumService.isPremium.value;

      return Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text('review'.tr),
            actions: [
              DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: _locale,
                  icon: const Icon(Icons.language),
                  onChanged: (locale) {
                    if (locale == null) return;
                    setState(() => _locale = locale);
                    Get.updateLocale(locale);
                  },
                  items: const [
                    Locale('en', 'US'),
                    Locale('fa', 'IR'),
                  ]
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
          body: RefreshIndicator(
            onRefresh: _loadReview,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReviewHeader(isLoading: _isLoading, issues: _issues),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'review_grid_title'.tr,
                    subtitle: 'review_grid_subtitle'.tr,
                    action: _isLoading
                        ? null
                        : TextButton.icon(
                            onPressed: _loadReview,
                            icon: const Icon(Icons.refresh),
                            label: Text('review_refresh'.tr),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _ReviewGrid(sections: _buildSections()),
                  const SizedBox(height: 20),
                  _SectionHeader(
                    title: 'review_quick_links'.tr,
                    subtitle: 'review_quick_links_subtitle'.tr,
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _QuickLinks(issues: _issues),
                  const SizedBox(height: 20),
                  _SectionHeader(
                    title: 'review_pdf_preview'.tr,
                    subtitle: 'review_pdf_preview_subtitle'.tr,
                  ),
                  const SizedBox(height: 12),
                  _TemplatePreview(
                    selectedTemplate: _selectedTemplate,
                    onTemplateSelected: (template) =>
                        _onTemplateSelected(template, isPremium),
                    isPremium: isPremium,
                    pdfBuilder: (format) => _pdfService.generateResumePdf(
                      template: _selectedTemplate,
                      isRtl: _isRtl,
                    ),
                    previewKey: _previewKey,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ReviewIssue {
  const _ReviewIssue({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
}

class _SectionReview {
  const _SectionReview({
    required this.titleKey,
    required this.route,
    required this.icon,
    required this.itemCount,
    required this.issueCount,
  });

  final String titleKey;
  final String route;
  final IconData icon;
  final int itemCount;
  final int issueCount;

  _SectionStatus get status {
    if (issueCount > 0) return _SectionStatus.needsWork;
    if (itemCount == 0) return _SectionStatus.empty;
    return _SectionStatus.pass;
  }
}

enum _SectionStatus { pass, needsWork, empty }

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.isLoading, required this.issues});

  final bool isLoading;
  final List<_ReviewIssue> issues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color badgeColor = issues.isEmpty
        ? Colors.green
        : (issues.length <= 3 ? Colors.orange : Colors.redAccent);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'review_page_title'.tr,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('review_page_subtitle'.tr, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          if (isLoading)
            const LinearProgressIndicator(minHeight: 4)
          else
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        issues.isEmpty
                            ? Icons.verified_outlined
                            : Icons.warning_amber_rounded,
                        color: badgeColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        issues.isEmpty
                            ? 'resume_review_empty_state'.tr
                            : 'issue_counter'.trParams({
                                'count': issues.length.toString(),
                              }),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: badgeColor, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReviewGrid extends StatelessWidget {
  const _ReviewGrid({required this.sections});

  final List<_SectionReview> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 960
            ? 3
            : constraints.maxWidth >= 680
                ? 2
                : 1;
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: sections
              .map(
                (section) => SizedBox(
                  width: itemWidth,
                  child: _SectionCard(section: section, theme: theme),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.theme});

  final _SectionReview section;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final status = section.status;
    final Color statusColor = switch (status) {
      _SectionStatus.pass => Colors.green,
      _SectionStatus.needsWork => Colors.redAccent,
      _SectionStatus.empty => Colors.orange,
    };

    final String statusLabel = switch (status) {
      _SectionStatus.pass => 'status_pass'.tr,
      _SectionStatus.needsWork => 'status_needs_work'.tr,
      _SectionStatus.empty => 'status_missing'.tr,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Get.toNamed(section.route),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardStroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.12),
                  foregroundColor: statusColor,
                  child: Icon(section.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.titleKey.tr,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            label: Text(statusLabel),
                            backgroundColor: statusColor.withOpacity(0.12),
                            labelStyle: theme.textTheme.labelMedium
                                ?.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'items_count'.trParams({
                              'count': section.itemCount.toString(),
                            }),
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            'issue_counter'.trParams({
                              'count': section.issueCount.toString(),
                            }),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              status == _SectionStatus.pass
                  ? 'section_pass_message'.tr
                  : 'section_fix_message'.tr,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => Get.toNamed(section.route),
                icon: const Icon(Icons.open_in_new),
                label: Text('open_section'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.issues});

  final List<_ReviewIssue> issues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (issues.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardStroke),
        ),
        child: Text('resume_review_empty_state'.tr),
      );
    }

    return Column(
      children: issues
          .map(
            (issue) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardStroke),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    child: Icon(issue.icon),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue.title,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(issue.description, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () => Get.toNamed(issue.route),
                              icon: const Icon(Icons.chevron_right),
                              label: Text('open_section'.tr),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Get.toNamed(issue.route),
                              icon: const Icon(Icons.edit_note_outlined),
                              label: Text('quick_fix'.tr),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({
    required this.selectedTemplate,
    required this.onTemplateSelected,
    required this.isPremium,
    required this.pdfBuilder,
    required this.previewKey,
  });

  final ResumeTemplate selectedTemplate;
  final void Function(ResumeTemplate) onTemplateSelected;
  final bool isPremium;
  final Future<List<int>> Function(PdfPageFormat) pdfBuilder;
  final Key previewKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = [
      (
        template: ResumeTemplate.minimal,
        title: 'template_minimal'.tr,
        description: 'template_minimal_desc'.tr,
        icon: Icons.auto_awesome_motion,
        locked: false,
      ),
      (
        template: ResumeTemplate.ats,
        title: 'template_ats'.tr,
        description: 'template_ats_desc'.tr,
        icon: Icons.description_outlined,
        locked: false,
      ),
      (
        template: ResumeTemplate.modern,
        title: 'template_modern'.tr,
        description: 'template_modern_desc'.tr,
        icon: Icons.timeline_rounded,
        locked: false,
      ),
      (
        template: ResumeTemplate.elegant,
        title: 'template_elegant'.tr,
        description: 'template_elegant_desc'.tr,
        icon: Icons.workspace_premium,
        locked: !isPremium,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final template = templates[index];
                final bool isSelected = selectedTemplate == template.template;
                return InkWell(
                  onTap: () => onTemplateSelected(template.template),
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardStroke,
                      ),
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : theme.colorScheme.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(template.icon,
                                color: isSelected
                                    ? AppColors.primary
                                    : theme.iconTheme.color),
                            const SizedBox(width: 8),
                            Text(
                              template.title,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (template.locked)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(start: 6.0),
                                child: Icon(Icons.lock_outline,
                                    size: 16, color: theme.disabledColor),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          template.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemCount: templates.length,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'template_preview_label'.tr,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 420,
                  child: PdfPreview(
                    key: previewKey,
                    build: pdfBuilder,
                    allowSharing: false,
                    allowPrinting: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    useActions: false,
                    scrollViewDecoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardStroke),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle, this.action});

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

