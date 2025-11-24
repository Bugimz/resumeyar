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

enum ResumeTemplate { minimal, modern }

class PdfService {
  PdfService({
    required this.resumeProfileRepository,
    required this.workExperienceRepository,
    required this.educationRepository,
    required this.skillRepository,
    required this.projectRepository,
  });

  final ResumeProfileRepository resumeProfileRepository;
  final WorkExperienceRepository workExperienceRepository;
  final EducationRepository educationRepository;
  final SkillRepository skillRepository;
  final ProjectRepository projectRepository;

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
            ),
          ResumeTemplate.modern => _buildModernTemplate(
              profile,
              workExperiences,
              educations,
              skills,
              projects,
              isRtl,
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
        pw.Text(
          profile.email,
          textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
        ),
        pw.Text(
          profile.phone,
          textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          profile.summary,
          textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
        ),
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
    return pw.Column(
      crossAxisAlignment:
          isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Skills', isRtl),
        if (skills.isEmpty) pw.Text('No skills added yet'),
        ...skills.map(
          (skill) => pw.Row(
            mainAxisAlignment: isRtl
                ? pw.MainAxisAlignment.end
                : pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 6,
                height: 6,
                margin: const pw.EdgeInsets.only(top: 3),
                decoration: const pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  '${skill.name} (${skill.level})',
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
              ),
            ],
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
  ) {
    return [
      _buildProfileSection(profile, isRtl),
      _buildExperienceSection(workExperiences, isRtl),
      _buildEducationSection(educations, isRtl),
      _buildSkillSection(skills, isRtl),
      _buildProjectSection(projects, isRtl),
    ];
  }

  List<pw.Widget> _buildModernTemplate(
    ResumeProfile? profile,
    List<WorkExperience> workExperiences,
    List<Education> educations,
    List<Skill> skills,
    List<Project> projects,
    bool isRtl,
  ) {
    return [
      if (profile != null)
        _buildModernHeader(profile, isRtl)
      else
        _buildProfileSection(profile, isRtl),
      pw.Divider(),
      _buildExperienceSection(workExperiences, isRtl),
      pw.Divider(),
      _buildEducationSection(educations, isRtl),
      pw.Divider(),
      _buildSkillSection(skills, isRtl),
      pw.Divider(),
      _buildProjectSection(projects, isRtl),
    ];
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
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: isRtl
                      ? pw.MainAxisAlignment.end
                      : pw.MainAxisAlignment.start,
                  children: [
                    pw.Icon(pw.IconData(0xe0be), size: 14),
                    pw.SizedBox(width: 6),
                    pw.Text(profile.email),
                    pw.SizedBox(width: 12),
                    pw.Icon(pw.IconData(0xe0cd), size: 14),
                    pw.SizedBox(width: 6),
                    pw.Text(profile.phone),
                  ],
                ),
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
}
