import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/models/education.dart';
import '../data/models/interest.dart';
import '../data/models/language.dart';
import '../data/models/project.dart';
import '../data/models/resume_profile.dart';
import '../data/models/certification.dart';
import '../data/models/skill.dart';
import '../data/models/work_experience.dart';
import '../data/repositories/education_repository.dart';
import '../data/repositories/interest_repository.dart';
import '../data/repositories/language_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/resume_profile_repository.dart';
import '../data/repositories/certification_repository.dart';
import '../data/repositories/skill_repository.dart';
import '../data/repositories/work_experience_repository.dart';
import '../utils/resume_sections.dart';
import 'settings_service.dart';

enum ResumeTemplate { minimal, modern, elegant, ats }

class _PdfPalette {
  const _PdfPalette({
    required this.text,
    required this.subtleText,
    required this.surface,
    required this.surfaceAlt,
    required this.accent,
    required this.border,
    required this.background,
  });

  final PdfColor text;
  final PdfColor subtleText;
  final PdfColor surface;
  final PdfColor surfaceAlt;
  final PdfColor accent;
  final PdfColor border;
  final PdfColor background;
}

class PdfService {
  PdfService({
    required this.resumeProfileRepository,
    required this.workExperienceRepository,
    required this.educationRepository,
    required this.certificationRepository,
    required this.languageRepository,
    required this.interestRepository,
    required this.skillRepository,
    required this.projectRepository,
    SettingsService? settingsService,
  }) : settingsService = settingsService ?? SettingsService();

  final ResumeProfileRepository resumeProfileRepository;
  final WorkExperienceRepository workExperienceRepository;
  final EducationRepository educationRepository;
  final CertificationRepository certificationRepository;
  final LanguageRepository languageRepository;
  final InterestRepository interestRepository;
  final SkillRepository skillRepository;
  final ProjectRepository projectRepository;
  final SettingsService settingsService;

  late _PdfPalette _currentPalette;

  Future<Uint8List> generateResumePdf({
    required ResumeTemplate template,
    bool isRtl = false,
  }) async {
    final ResumeProfile? profile = await _getPrimaryProfile();
    final List<WorkExperience> workExperiences =
        await workExperienceRepository.getAll();
    final List<Education> educations = await educationRepository.getAll();
    final List<Certification> certifications = await certificationRepository.getAll();
    final List<Language> languages = await languageRepository.getAll();
    final List<Interest> interests = await interestRepository.getAll();
    final List<Skill> skills = await skillRepository.getAll();
    final List<Project> projects = await projectRepository.getAll();
    final List<ResumeSection> sectionOrder =
        await settingsService.loadResumeSectionOrder();
    final Set<ResumeSection> hiddenSections =
        await settingsService.loadHiddenSections();
    final bool showGpa = await settingsService.loadGpaVisibility();
    final PdfPageFormat pageFormat = await settingsService.loadPageFormat();
    final PdfThemeMode pdfTheme = await settingsService.loadPdfTheme();
    final Map<String, pw.MemoryImage> projectImages =
        await _loadProjectImages(projects);

    final filteredSectionOrder =
        sectionOrder.where((section) => !hiddenSections.contains(section)).toList();
    final palette = _paletteFor(pdfTheme);
    _currentPalette = palette;
    final margin = pageFormat == PdfPageFormat.a4
        ? const pw.EdgeInsets.fromLTRB(32, 36, 32, 36)
        : const pw.EdgeInsets.fromLTRB(28, 32, 28, 32);

    final baseFont = await PdfGoogleFonts.vazirmatnRegular();
    final boldFont = await PdfGoogleFonts.vazirmatnBold();
    final pageTheme = pw.PageTheme(
      pageFormat: pageFormat,
      margin: margin,
      textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      buildBackground: (context) => pw.Container(color: palette.background),
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        defaultTextStyle: pw.TextStyle(
          color: palette.text,
          fontSize: 11.5,
        ),
      ),
    );

    final defaultTextStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: 11.5,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) {
          final children = switch (template) {
            ResumeTemplate.minimal => _buildMinimalTemplate(
                profile,
                workExperiences,
                educations,
                skills,
                projects,
                isRtl,
                sectionOrder,
              ),
            ResumeTemplate.modern => _buildModernTemplate(
                profile,
                workExperiences,
                educations,
                skills,
                projects,
                isRtl,
                sectionOrder,
              ),
            ResumeTemplate.elegant => _buildElegantTemplate(
                profile,
                workExperiences,
                educations,
                skills,
                projects,
                isRtl,
                sectionOrder,
              ),
          };

          return [
            pw.DefaultTextStyle.merge(
              style: defaultTextStyle,
              child: pw.Column(children: children),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> shareResumePdf({
    required ResumeTemplate template,
    bool isRtl = false,
  }) async {
    final bytes = await generateResumePdf(
      template: template,
      isRtl: isRtl,
    );
    await Printing.sharePdf(bytes: bytes, filename: 'resume.pdf');
  }

  _PdfPalette _paletteFor(PdfThemeMode theme) {
    if (theme == PdfThemeMode.dark) {
      return const _PdfPalette(
        text: PdfColors.white,
        subtleText: PdfColors.grey300,
        surface: PdfColor.fromInt(0xFF1f2937),
        surfaceAlt: PdfColor.fromInt(0xFF111827),
        accent: PdfColors.amber300,
        border: PdfColors.grey600,
        background: PdfColor.fromInt(0xFF0b1020),
      );
    }

    return const _PdfPalette(
      text: PdfColors.black,
      subtleText: PdfColors.grey800,
      surface: PdfColors.white,
      surfaceAlt: PdfColors.grey100,
      accent: PdfColors.blue,
      border: PdfColors.grey300,
      background: PdfColors.white,
    );
  }

  Future<Map<String, pw.MemoryImage>> _loadProjectImages(
    List<Project> projects,
  ) async {
    final Map<String, pw.MemoryImage> images = {};
    for (final project in projects) {
      final url = project.thumbnailUrl;
      if (url.isEmpty) continue;

      try {
        final uri = Uri.parse(url);
        final client = HttpClient();
        final request = await client.getUrl(uri);
        final response = await request.close();
        final bytes = <int>[];
        await for (final chunk in response) {
          bytes.addAll(chunk);
        }
        if (bytes.isNotEmpty) {
          images[url] = pw.MemoryImage(Uint8List.fromList(bytes));
        }
      } catch (_) {
        continue;
      }
    }
    return images;
  }

  Future<ResumeProfile?> _getPrimaryProfile() async {
    final profiles = await resumeProfileRepository.getAll();
    if (profiles.isEmpty) {
      return null;
    }
    return profiles.first;
  }

  pw.Widget _buildSectionTitle(String title, bool isRtl) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: _currentPalette.accent,
        ),
        textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _buildProfileImage(
    String? path, {
    double size = 72,
  }) {
    if (path == null || path.isEmpty) {
      return pw.SizedBox();
    }

    final file = File(path);
    if (!file.existsSync()) {
      return pw.SizedBox();
    }

    final image = pw.MemoryImage(file.readAsBytesSync());
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: _currentPalette.border, width: 2),
      ),
      child: pw.ClipOval(
        child: pw.Image(image, fit: pw.BoxFit.cover),
      ),
    );
  }

  pw.Widget _buildContactRow(ResumeProfile profile, bool isRtl) {
    final List<pw.Widget> items = [];

    void addItem(String value, int iconCode) {
      if (value.isEmpty) {
        return;
      }
      items.add(
        pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Icon(pw.IconData(iconCode), size: 12),
            pw.SizedBox(width: 4),
            pw.Text(value),
          ],
        ),
      );
    }

    addItem(profile.location, 0xe0c8);
    addItem(profile.email, 0xe0be);
    addItem(profile.phone, 0xe0cd);
    addItem(profile.portfolioUrl, 0xe0c9);
    addItem(profile.linkedInUrl, 0xe80d);
    addItem(profile.githubUrl, 0xe86f);

    if (items.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: isRtl ? pw.WrapAlignment.end : pw.WrapAlignment.start,
      children: items,
    );
  }

  pw.Widget _buildProfileSection(ResumeProfile? profile, bool isRtl) {
    if (profile == null) {
      return pw.Column(
        crossAxisAlignment:
            isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Profile', isRtl),
          pw.Text('No profile information available'),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profile', isRtl),
        if (profile.imagePath != null)
          pw.Align(
            alignment:
                isRtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            child: _buildProfileImage(profile.imagePath, size: 80),
          ),
        if (profile.imagePath != null) pw.SizedBox(height: 12),
        pw.Text(
          profile.fullName,
          style: const pw.TextStyle(fontSize: 16),
          textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
        ),
        if (profile.jobTitle.isNotEmpty)
          pw.Text(
            profile.jobTitle,
            style: pw.TextStyle(
              fontSize: 12,
              color: _currentPalette.subtleText,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
          ),
        pw.Text(
          profile.summary,
          textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
        ),
        pw.SizedBox(height: 8),
        _buildContactRow(profile, isRtl),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildExperienceSection(
    List<WorkExperience> workExperiences,
    bool isRtl,
  ) {
    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Experience', isRtl),
        ...workExperiences.map(
          (experience) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: isRtl
                  ? pw.CrossAxisAlignment.end
                  : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  experience.position,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                pw.Text(
                  '${experience.company} (${experience.startDate} - ${experience.endDate})',
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                pw.Text(
                  experience.description,
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
              ],
            ),
          ),
        ),
        if (workExperiences.isEmpty) pw.Text('No experience added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildEducationSection(
    List<Education> educations,
    bool isRtl,
    bool showGpa,
  ) {
    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Education', isRtl),
        ...educations.map(
          (education) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: isRtl
                  ? pw.CrossAxisAlignment.end
                  : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  education.school,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                pw.Text(
                  '${education.degree} in ${education.fieldOfStudy}',
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                if (showGpa && education.showGpa && education.gpa != null)
                  pw.Text(
                    'GPA: ${education.gpa!.toStringAsFixed(2)}',
                    textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                  ),
                pw.Text(
                  '${education.startDate} - ${education.endDate}',
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                pw.Text(
                  education.description,
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                if (education.honors.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: education.honors
                          .map((honor) => pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(12),
                                  color: PdfColor.fromHex('#e0f7fa'),
                                ),
                                child: pw.Text(honor),
                              ))
                          .toList(),
                    ),
                  ),
                if (education.courses.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: education.courses
                          .map((course) => pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(12),
                                  color: PdfColor.fromHex('#e8eaf6'),
                                ),
                                child: pw.Text(course),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (educations.isEmpty) pw.Text('No education added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildCertificationSection(
      List<Certification> certifications, bool isRtl) {
    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Certifications', isRtl),
        ...certifications.map(
          (certification) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: isRtl
                  ? pw.CrossAxisAlignment.end
                  : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  certification.name,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                pw.Text(
                  '${certification.issuer} • ${certification.issueDate}',
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                if (certification.credentialUrl.isNotEmpty)
                  pw.UrlLink(
                    destination: certification.credentialUrl,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        certification.credentialUrl,
                        style: const pw.TextStyle(
                          color: PdfColors.blue,
                          decoration: pw.TextDecoration.underline,
                        ),
                        textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (certifications.isEmpty) pw.Text('No certifications added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildLanguageSection(List<Language> languages, bool isRtl) {
    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Languages', isRtl),
        pw.Wrap(
          spacing: 8,
          runSpacing: 6,
          children: languages
              .map(
                (language) => pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: PdfColors.blueGrey300, width: 0.8),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        language.name,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text('(${language.level})'),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        if (languages.isEmpty) pw.Text('No languages added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildInterestSection(List<Interest> interests, bool isRtl) {
    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Interests', isRtl),
        ...interests.map(
          (interest) => pw.Bullet(
            text: interest.details.isNotEmpty
                ? '${interest.title}: ${interest.details}'
                : interest.title,
            textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
          ),
        ),
        if (interests.isEmpty) pw.Text('No interests added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildSkillSection(List<Skill> skills, bool isRtl) {
    final categorySkills = SkillCategory.values
        .map(
          (category) => MapEntry(
            category,
            skills
                .where((skill) => skill.category == category)
                .toList()
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
          ),
        )
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Skills', isRtl),
        if (skills.isEmpty) pw.Text('No skills added yet'),
        ...categorySkills.map(
          (entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment:
                  isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.key.name[0].toUpperCase() + entry.key.name.substring(1),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.value
                      .map(
                        (skill) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(14),
                          ),
                          child: pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                skill.name,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              if (skill.displayLevel.isNotEmpty) ...[
                                pw.SizedBox(width: 6),
                                pw.Container(
                                  padding:
                                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.blue100,
                                    borderRadius: pw.BorderRadius.circular(10),
                                  ),
                                  child: pw.Text(
                                    skill.displayLevel,
                                    style: const pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                              if (skill.levelProgress != null) ...[
                                pw.SizedBox(width: 6),
                                pw.Container(
                                  width: 50,
                                  height: 4,
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey400,
                                    borderRadius: pw.BorderRadius.circular(2),
                                  ),
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Container(
                                      width: 50 * (skill.levelProgress ?? 0),
                                      height: 4,
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.blue,
                                        borderRadius: pw.BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildProjectSection(
    List<Project> projects,
    bool isRtl,
    Map<String, pw.MemoryImage> projectImages,
  ) {
    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Projects', isRtl),
        ...projects.map(
          (project) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: isRtl
                  ? pw.CrossAxisAlignment.end
                  : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  project.title,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                if (project.role.isNotEmpty)
                  pw.Text(
                    project.role,
                    style:
                        pw.TextStyle(fontSize: 10, color: _currentPalette.subtleText),
                    textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                  ),
                pw.Text(
                  project.description,
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                if (project.responsibilities.isNotEmpty)
                  pw.Column(
                    crossAxisAlignment: isRtl
                        ? pw.CrossAxisAlignment.end
                        : pw.CrossAxisAlignment.start,
                    children: project.responsibilities
                        .map(
                          (item) => pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('• '),
                              pw.Expanded(child: pw.Text(item)),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                if (project.techTags.isNotEmpty)
                  pw.Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: project.techTags
                        .map((tag) => pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: _currentPalette.surfaceAlt,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(tag,
                                  style: const pw.TextStyle(fontSize: 10)),
                            ))
                        .toList(),
                  ),
                if (project.thumbnailUrl.isNotEmpty &&
                    projectImages.containsKey(project.thumbnailUrl))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 8),
                    child: pw.ClipRRect(
                      horizontalRadius: 6,
                      verticalRadius: 6,
                      child: pw.Container(
                        height: 120,
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: _currentPalette.border, width: 0.5),
                        ),
                        child: pw.FittedBox(
                          fit: pw.BoxFit.cover,
                          alignment: pw.Alignment.center,
                          child: pw.Image(projectImages[project.thumbnailUrl]!),
                        ),
                      ),
                    ),
                  ),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (project.link.isNotEmpty)
                      _buildProjectLink('Link', project.link, isRtl),
                    if (project.demoLink.isNotEmpty)
                      _buildProjectLink('Demo', project.demoLink, isRtl),
                    if (project.githubLink.isNotEmpty)
                      _buildProjectLink('GitHub', project.githubLink, isRtl),
                    if (project.liveLink.isNotEmpty)
                      _buildProjectLink('Live', project.liveLink, isRtl),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (projects.isEmpty) pw.Text('No projects added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildProjectLink(String label, String url, bool isRtl) {
    return pw.UrlLink(
      destination: url,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: PdfColors.blueGrey300, width: 0.5),
        ),
        child: pw.Text(
          label,
          textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue),
        ),
      ),
    );
  }

  List<pw.Widget> _buildMinimalTemplate(
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Certification> certifications,
    List<Language> languages,
    List<Interest> interests,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
    List<ResumeSection> sectionOrder,
    bool showGpa,
    Map<String, pw.MemoryImage> projectImages,
  ) {
    return _buildSectionsByOrder(
      sectionOrder,
      ResumeTemplate.minimal,
      profile,
      workExperiences,
      educations,
      certifications,
      languages,
      interests,
      skills,
      projects,
      isRtl,
      showGpa,
      projectImages,
    );
  }

  List<pw.Widget> _buildModernTemplate(
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Certification> certifications,
    List<Language> languages,
    List<Interest> interests,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
    List<ResumeSection> sectionOrder,
    bool showGpa,
    Map<String, pw.MemoryImage> projectImages,
  ) {
    return _buildSectionsByOrder(
      sectionOrder,
      ResumeTemplate.modern,
      profile,
      workExperiences,
      educations,
      certifications,
      languages,
      interests,
      skills,
      projects,
      isRtl,
      showGpa,
      projectImages,
    );
  }

  List<pw.Widget> _buildElegantTemplate(
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Certification> certifications,
    List<Language> languages,
    List<Interest> interests,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
    List<ResumeSection> sectionOrder,
    bool showGpa,
    Map<String, pw.MemoryImage> projectImages,
  ) {
    return _buildSectionsByOrder(
      sectionOrder,
      ResumeTemplate.elegant,
      profile,
      workExperiences,
      educations,
      certifications,
      languages,
      interests,
      skills,
      projects,
      isRtl,
      showGpa,
      projectImages,
    );
  }

  List<pw.Widget> _buildAtsTemplate(
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Certification> certifications,
    List<Language> languages,
    List<Interest> interests,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
    List<ResumeSection> sectionOrder,
    bool showGpa,
    Map<String, pw.MemoryImage> projectImages,
  ) {
    return _buildSectionsByOrder(
      sectionOrder,
      ResumeTemplate.ats,
      profile,
      workExperiences,
      educations,
      certifications,
      languages,
      interests,
      skills,
      projects,
      isRtl,
      showGpa,
      projectImages,
    );
  }

  List<pw.Widget> _buildSectionsByOrder(
    List<ResumeSection> sectionOrder,
    ResumeTemplate template,
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Certification> certifications,
    List<Language> languages,
    List<Interest> interests,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
    bool showGpa,
    Map<String, pw.MemoryImage> projectImages,
  ) {
    final List<pw.Widget> widgets = [];

    for (var i = 0; i < sectionOrder.length; i++) {
      final section = sectionOrder[i];
      final sectionWidget = switch (section) {
        ResumeSection.profile => switch (template) {
            ResumeTemplate.modern when profile != null =>
              _buildModernHeader(profile, isRtl),
            ResumeTemplate.elegant when profile != null =>
              _buildElegantHeader(profile, isRtl),
            ResumeTemplate.ats when profile != null =>
              _buildAtsHeader(profile, isRtl),
            _ => _buildProfileSection(profile, isRtl),
          },
        ResumeSection.workExperience =>
            _buildExperienceSection(workExperiences, isRtl),
        ResumeSection.education =>
            _buildEducationSection(educations, isRtl, showGpa),
        ResumeSection.certifications =>
            _buildCertificationSection(certifications, isRtl),
        ResumeSection.languages => _buildLanguageSection(languages, isRtl),
        ResumeSection.interests => _buildInterestSection(interests, isRtl),
        ResumeSection.skills => _buildSkillSection(skills, isRtl),
        ResumeSection.projects =>
            _buildProjectSection(projects, isRtl, projectImages),
      };

      widgets.add(sectionWidget);

      if (i != sectionOrder.length - 1) {
        if (template == ResumeTemplate.modern) {
          widgets.add(pw.Divider());
        } else if (template == ResumeTemplate.elegant) {
          widgets.add(
            pw.Divider(
              color: PdfColors.blueGrey300,
              thickness: 0.7,
            ),
          );
        } else if (template == ResumeTemplate.ats) {
          widgets.add(
            pw.Divider(
              color: _currentPalette.border,
              thickness: 0.5,
            ),
          );
        }
      }
    }

    return widgets;
  }

  pw.Widget _buildAtsHeader(ResumeProfile profile, bool isRtl) {
    final alignment = isRtl ? pw.TextAlign.right : pw.TextAlign.left;

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _currentPalette.surface,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _currentPalette.border, width: 0.6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (profile.imagePath != null && profile.imagePath!.isNotEmpty) ...[
            _buildProfileImage(profile.imagePath, size: 70),
            pw.SizedBox(width: 14),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  profile.fullName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: alignment,
                ),
                if (profile.jobTitle.isNotEmpty)
                  pw.Text(
                    profile.jobTitle,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: _currentPalette.subtleText,
                    ),
                    textAlign: alignment,
                  ),
                pw.SizedBox(height: 6),
                _buildContactRow(profile, isRtl),
                if (profile.summary.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    profile.summary,
                    textAlign: alignment,
                    maxLines: 4,
                    overflow: pw.TextOverflow.clip,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildModernHeader(ResumeProfile profile, bool isRtl) {
    final alignment = isRtl ? pw.TextAlign.right : pw.TextAlign.left;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (profile.imagePath != null) ...[
            _buildProfileImage(profile.imagePath, size: 90),
            pw.SizedBox(width: 16),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  profile.fullName,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: alignment,
                ),
                if (profile.jobTitle.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    profile.jobTitle,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: alignment,
                  ),
                ],
                if (profile.location.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: isRtl
                        ? pw.MainAxisAlignment.end
                        : pw.MainAxisAlignment.start,
                    children: [
                      pw.Icon(pw.IconData(0xe0c8), size: 12),
                      pw.SizedBox(width: 6),
                      pw.Text(profile.location),
                    ],
                  ),
                ],
                pw.SizedBox(height: 8),
                _buildContactRow(profile, isRtl),
                pw.SizedBox(height: 12),
                pw.Text(
                  profile.summary,
                  textAlign: alignment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildElegantHeader(ResumeProfile profile, bool isRtl) {
    final alignment = isRtl ? pw.TextAlign.right : pw.TextAlign.left;

    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blueGrey900, PdfColors.blueGrey600],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (profile.imagePath != null) ...[
            _buildProfileImage(profile.imagePath, size: 88),
            pw.SizedBox(width: 16),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  profile.fullName,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  textAlign: alignment,
                ),
                if (profile.jobTitle.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    profile.jobTitle,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: alignment,
                  ),
                ],
                pw.SizedBox(height: 6),
                pw.Text(
                  profile.summary,
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                  textAlign: alignment,
                ),
                pw.SizedBox(height: 12),
                _buildContactRow(profile, isRtl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
