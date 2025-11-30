import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../../services/pdf_service.dart';
import '../../services/premium_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';
import '../../data/repositories/education_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/resume_profile_repository.dart';
import '../../data/repositories/skill_repository.dart';
import '../../data/repositories/work_experience_repository.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ResumeProfileRepository _profileRepository = ResumeProfileRepository();
  final WorkExperienceRepository _workRepository = WorkExperienceRepository();
  final EducationRepository _educationRepository = EducationRepository();
  final SkillRepository _skillRepository = SkillRepository();
  final ProjectRepository _projectRepository = ProjectRepository();

  late final PdfService _pdfService = PdfService(
    resumeProfileRepository: _profileRepository,
    workExperienceRepository: _workRepository,
    educationRepository: _educationRepository,
    skillRepository: _skillRepository,
    projectRepository: _projectRepository,
  );

  final ThemeController _themeController = Get.find<ThemeController>();
  final PremiumService _premiumService = Get.find<PremiumService>();

  Locale _locale = Get.locale ?? const Locale('en', 'US');
  ResumeTemplate _selectedTemplate = ResumeTemplate.minimal;

  bool _isLoadingCounts = true;
  Map<String, int> _counts = {
    'profiles': 0,
    'work': 0,
    'education': 0,
    'skills': 0,
    'projects': 0,
  };

  final List<Locale> _supportedLocales = const [
    Locale('en', 'US'),
    Locale('fa', 'IR'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  bool get _isRtl => _locale.languageCode == 'fa';

  Future<void> _loadCounts() async {
    setState(() => _isLoadingCounts = true);

    final profiles = await _profileRepository.getAll();
    final work = await _workRepository.getAll();
    final education = await _educationRepository.getAll();
    final skills = await _skillRepository.getAll();
    final projects = await _projectRepository.getAll();

    if (!mounted) return;

    setState(() {
      _counts = {
        'profiles': profiles.length,
        'work': work.length,
        'education': education.length,
        'skills': skills.length,
        'projects': projects.length,
      };
      _isLoadingCounts = false;
    });
  }

  Future<void> _downloadPdf() async {
    try {
      await _pdfService.shareResumePdf(
        template: _selectedTemplate,
        isRtl: _isRtl,
      );
      Get.snackbar('success'.tr, 'resume_pdf_generated'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_generate_pdf'.trParams({'error': '$e'}));
    }
  }

  void _onTemplateSelected(ResumeTemplate template, bool isPremium) {
    if (template == ResumeTemplate.elegant && !isPremium) {
      Get.snackbar('premium_required'.tr, 'premium_template'.tr);
      return;
    }
    setState(() => _selectedTemplate = template);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPremium = _premiumService.isPremium.value;

      return Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text('app_title'.tr),
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
          body: RefreshIndicator(
            onRefresh: _loadCounts,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _HeroCard(isPremium: isPremium, onUpgrade: _premiumService.buyPremium),
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'template_gallery_title'.tr,
                  subtitle: 'template_gallery_subtitle'.tr,
                ),
                const SizedBox(height: 12),
                _TemplateSelector(
                  isPremium: isPremium,
                  selectedTemplate: _selectedTemplate,
                  onTemplateSelected: (template) =>
                      _onTemplateSelected(template, isPremium),
                ),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'resume_snapshot'.tr,
                  subtitle: 'resume_snapshot_subtitle'.tr,
                  action:
                      _isLoadingCounts ? null : TextButton(onPressed: _loadCounts, child: Text('refresh'.tr)),
                ),
                const SizedBox(height: 12),
                _isLoadingCounts
                    ? const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ))
                    : _StatsGrid(counts: _counts),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'quick_actions'.tr,
                  subtitle: 'quick_actions_subtitle'.tr,
                ),
                const SizedBox(height: 12),
                const _NavigationGrid(),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _downloadPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  label: Text('download_pdf'.tr),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.isPremium, required this.onUpgrade});

  final bool isPremium;
  final Future<void> Function() onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final iconHeight = isCompact ? 84.0 : 96.0;
        final iconWidth = isCompact ? 64.0 : 72.0;
        final iconSize = isCompact ? 32.0 : 40.0;

        final trailingIcon = Container(
          height: iconHeight,
          width: iconWidth,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(
            Icons.description_outlined,
            size: iconSize,
            color: Colors.white,
          ),
        );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                isPremium ? 'premium_active_title'.tr : 'premium_title'.tr,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPremium ? 'premium_active_message'.tr : 'hero_title'.tr,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isPremium ? 'hero_premium_body'.tr : 'hero_body'.tr,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (!isPremium)
                  ElevatedButton(
                    onPressed: onUpgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                    ),
                    child: Text('upgrade_now'.tr),
                  )
                else
                  const Icon(Icons.workspace_premium, color: Colors.white),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    isPremium ? 'premium_active_message'.tr : 'premium_subtitle'.tr,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 12),
                    Align(alignment: AlignmentDirectional.centerStart, child: trailingIcon),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: 12),
                    trailingIcon,
                  ],
                ),
        );
      },
    );
  }
}

class _TemplateSelector extends StatelessWidget {
  const _TemplateSelector({
    required this.isPremium,
    required this.selectedTemplate,
    required this.onTemplateSelected,
  });

  final bool isPremium;
  final ResumeTemplate selectedTemplate;
  final void Function(ResumeTemplate) onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth =
        (screenWidth * 0.6).clamp(180.0, 260.0).toDouble();
    final double listHeight = screenWidth < 360 ? 170.0 : 150.0;
    final templates = [
      (
        template: ResumeTemplate.minimal,
        title: 'template_minimal'.tr,
        description: 'template_minimal_desc'.tr,
        icon: Icons.auto_awesome_motion,
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

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = templates[index];
          final isSelected = selectedTemplate == item.template;

          return GestureDetector(
            onTap: () => onTemplateSelected(item.template),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: cardWidth,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardStroke,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        foregroundColor: AppColors.primaryDark,
                        child: Icon(item.icon),
                      ),
                      const Spacer(),
                      if (item.locked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                'gold_badge'.tr,
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: Colors.amber.shade900),
                              ),
                            ],
                          ),
                        )
                      else if (isSelected)
                        Icon(Icons.check_circle, color: AppColors.primaryDark),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final items = [
      (_StatCardData(labelKey: 'profile', count: counts['profiles'] ?? 0, icon: Icons.person_outline)),
      (_StatCardData(labelKey: 'work_experience', count: counts['work'] ?? 0, icon: Icons.badge_outlined)),
      (_StatCardData(labelKey: 'education', count: counts['education'] ?? 0, icon: Icons.school_outlined)),
      (_StatCardData(labelKey: 'skills', count: counts['skills'] ?? 0, icon: Icons.star_border)),
      (_StatCardData(labelKey: 'projects', count: counts['projects'] ?? 0, icon: Icons.widgets_outlined)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 640
                ? 2
                : 1;
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _StatCard(
                    data: item,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.12),
            foregroundColor: AppColors.primaryDark,
            child: Icon(data.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.labelKey.tr,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'items_count'.trParams({'count': '${data.count}'}),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.labelKey,
    required this.count,
    required this.icon,
  });

  final String labelKey;
  final int count;
  final IconData icon;
}

class _NavigationGrid extends StatelessWidget {
  const _NavigationGrid();

  @override
  Widget build(BuildContext context) {
    final tiles = const [
      _NavigationTile(title: 'profile', route: Routes.profile, icon: Icons.person_outline),
      _NavigationTile(title: 'work_experience', route: Routes.work, icon: Icons.badge_outlined),
      _NavigationTile(title: 'education', route: Routes.education, icon: Icons.school_outlined),
      _NavigationTile(title: 'skills', route: Routes.skills, icon: Icons.star_border),
      _NavigationTile(title: 'projects', route: Routes.projects, icon: Icons.widgets_outlined),
      _NavigationTile(title: 'settings', route: Routes.settings, icon: Icons.settings_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 640
                ? 2
                : 1;
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles
              .map(
                (tile) => SizedBox(
                  width: itemWidth,
                  child: tile,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({required this.title, required this.route, required this.icon});

  final String title;
  final String route;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Get.toNamed(route),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardStroke),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primaryDark,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title.tr,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
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
