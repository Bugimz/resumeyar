import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/models/education.dart';
import '../data/models/project.dart';
import '../data/models/resume_profile.dart';
import '../data/models/skill.dart';
import '../data/models/work_experience.dart';
import '../data/repositories/education_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/resume_profile_repository.dart';
import '../data/repositories/skill_repository.dart';
import '../data/repositories/work_experience_repository.dart';
import '../utils/resume_sections.dart';
import 'settings_service.dart';

enum ResumeTemplate { minimal, modern, elegant }

class PdfService {
  PdfService({
    required this.resumeProfileRepository,
    required this.workExperienceRepository,
    required this.educationRepository,
    required this.skillRepository,
    required this.projectRepository,
    SettingsService? settingsService,
  }) : settingsService = settingsService ?? SettingsService();

  final ResumeProfileRepository resumeProfileRepository;
  final WorkExperienceRepository workExperienceRepository;
  final EducationRepository educationRepository;
  final SkillRepository skillRepository;
  final ProjectRepository projectRepository;
  final SettingsService settingsService;

  Future<Uint8List> generateResumePdf({
    required ResumeTemplate template,
    bool isRtl = false,
  }) async {
    final ResumeProfile? profile = await _getPrimaryProfile();
    final List<WorkExperience> workExperiences =
        await workExperienceRepository.getAll();
    final List<Education> educations = await educationRepository.getAll();
    final List<Skill> skills = await skillRepository.getAll();
    final List<Project> projects = await projectRepository.getAll();
    final List<ResumeSection> sectionOrder =
        await settingsService.loadResumeSectionOrder();

    final baseFont = await PdfGoogleFonts.vazirmatnRegular();
    final boldFont = await PdfGoogleFonts.vazirmatnBold();
    final pageTheme = pw.PageTheme(
      textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => switch (template) {
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
        ),
        textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _buildProfileImage(String? path, {double size = 72}) {
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
        border: pw.Border.all(color: PdfColors.grey300, width: 2),
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
              color: PdfColors.grey800,
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

  pw.Widget _buildEducationSection(List<Education> educations, bool isRtl) {
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
                pw.Text(
                  '${education.startDate} - ${education.endDate}',
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                pw.Text(
                  education.description,
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
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

  pw.Widget _buildProjectSection(List<Project> projects, bool isRtl) {
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
                pw.Text(
                  project.description,
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                if (project.link.isNotEmpty)
                  pw.Text(
                    project.link,
                    textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
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

  List<pw.Widget> _buildMinimalTemplate(
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
    List<ResumeSection> sectionOrder,
  ) {
    return _buildSectionsByOrder(
      sectionOrder,
      ResumeTemplate.minimal,
      profile,
      workExperiences,
      educations,
      skills,
      projects,
      isRtl,
    );
  }

  List<pw.Widget> _buildModernTemplate(
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
    List<ResumeSection> sectionOrder,
  ) {
    return _buildSectionsByOrder(
      sectionOrder,
      ResumeTemplate.modern,
      profile,
      workExperiences,
      educations,
      skills,
      projects,
      isRtl,
    );
  }

  List<pw.Widget> _buildElegantTemplate(
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
    List<ResumeSection> sectionOrder,
  ) {
    return _buildSectionsByOrder(
      sectionOrder,
      ResumeTemplate.elegant,
      profile,
      workExperiences,
      educations,
      skills,
      projects,
      isRtl,
    );
  }

  List<pw.Widget> _buildSectionsByOrder(
    List<ResumeSection> sectionOrder,
    ResumeTemplate template,
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
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
            _ => _buildProfileSection(profile, isRtl),
          },
        ResumeSection.workExperience =>
            _buildExperienceSection(workExperiences, isRtl),
        ResumeSection.education => _buildEducationSection(educations, isRtl),
        ResumeSection.skills => _buildSkillSection(skills, isRtl),
        ResumeSection.projects => _buildProjectSection(projects, isRtl),
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
        }
      }
    }

    return widgets;
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
