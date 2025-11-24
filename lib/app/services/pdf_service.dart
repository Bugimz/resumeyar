import 'dart:typed_data';

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

  Future<Uint8List> generateResumePdf() async {
    final ResumeProfile? profile = await _getPrimaryProfile();
    final List<WorkExperience> workExperiences =
        await workExperienceRepository.getAll();
    final List<Education> educations = await educationRepository.getAll();
    final List<Skill> skills = await skillRepository.getAll();
    final List<Project> projects = await projectRepository.getAll();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildProfileSection(profile),
          _buildExperienceSection(workExperiences),
          _buildEducationSection(educations),
          _buildSkillSection(skills),
          _buildProjectSection(projects),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> shareResumePdf() async {
    final bytes = await generateResumePdf();
    await Printing.sharePdf(bytes: bytes, filename: 'resume.pdf');
  }

  Future<ResumeProfile?> _getPrimaryProfile() async {
    final profiles = await resumeProfileRepository.getAll();
    if (profiles.isEmpty) {
      return null;
    }
    return profiles.first;
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildProfileSection(ResumeProfile? profile) {
    if (profile == null) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Profile'),
          pw.Text('No profile information available'),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profile'),
        pw.Text(profile.fullName, style: const pw.TextStyle(fontSize: 16)),
        pw.Text(profile.email),
        pw.Text(profile.phone),
        pw.SizedBox(height: 8),
        pw.Text(profile.summary),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildExperienceSection(List<WorkExperience> workExperiences) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Experience'),
        ...workExperiences.map(
          (experience) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  experience.position,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('${experience.company} (${experience.startDate} - ${experience.endDate})'),
                pw.Text(experience.description),
              ],
            ),
          ),
        ),
        if (workExperiences.isEmpty) pw.Text('No experience added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildEducationSection(List<Education> educations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Education'),
        ...educations.map(
          (education) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  education.school,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('${education.degree} in ${education.fieldOfStudy}'),
                pw.Text('${education.startDate} - ${education.endDate}'),
                pw.Text(education.description),
              ],
            ),
          ),
        ),
        if (educations.isEmpty) pw.Text('No education added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildSkillSection(List<Skill> skills) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Skills'),
        if (skills.isEmpty) pw.Text('No skills added yet'),
        ...skills.map(
          (skill) => pw.Bullet(
            text: '${skill.name} (${skill.level})',
          ),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildProjectSection(List<Project> projects) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Projects'),
        ...projects.map(
          (project) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  project.title,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(project.description),
                if (project.link.isNotEmpty) pw.Text(project.link),
              ],
            ),
          ),
        ),
        if (projects.isEmpty) pw.Text('No projects added yet'),
        pw.SizedBox(height: 16),
      ],
    );
  }
}
