import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../../services/pdf_service.dart';
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

  Future<void> _downloadPdf() async {
    try {
      await _pdfService.shareResumePdf();
      Get.snackbar('Success', 'Resume PDF generated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResumeYar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('دانلود PDF'),
          ),
          const SizedBox(height: 16),
          const _NavigationTile(title: 'Profile', route: Routes.profile),
          const _NavigationTile(title: 'Work Experience', route: Routes.work),
          const _NavigationTile(title: 'Education', route: Routes.education),
          const _NavigationTile(title: 'Skills', route: Routes.skills),
          const _NavigationTile(title: 'Projects', route: Routes.projects),
        ],
      ),
    );
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
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(route),
      ),
    );
  }
}
