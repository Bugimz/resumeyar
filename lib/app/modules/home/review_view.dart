import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/education_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/resume_profile_repository.dart';
import '../../data/repositories/skill_repository.dart';
import '../../data/repositories/work_experience_repository.dart';

class ReviewView extends StatefulWidget {
  const ReviewView({super.key});

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  final ResumeProfileRepository _profileRepository = ResumeProfileRepository();
  final WorkExperienceRepository _workRepository = WorkExperienceRepository();
  final EducationRepository _educationRepository = EducationRepository();
  final SkillRepository _skillRepository = SkillRepository();
  final ProjectRepository _projectRepository = ProjectRepository();

  bool _isLoading = true;
  late Map<String, int> _counts;

  @override
  void initState() {
    super.initState();
    _counts = {};
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

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
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مرور سریع رزومه')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'این صفحه برای مرور سریع آماده‌سازی رزومه است. تعداد رکوردهای هر بخش و وضعیت کامل/ناقص نمایش داده می‌شود.',
                  ),
                  const SizedBox(height: 16),
                  _ChecklistTile(
                    title: 'پروفایل',
                    count: _counts['profiles'] ?? 0,
                    description: 'اطلاعات هویتی و خلاصه رزومه را کامل کنید.',
                    onTap: () => Get.toNamed('/profile'),
                  ),
                  _ChecklistTile(
                    title: 'سوابق کاری',
                    count: _counts['work'] ?? 0,
                    description: 'دستاوردها و متریک‌ها را به سوابق اضافه کنید.',
                    onTap: () => Get.toNamed('/work'),
                  ),
                  _ChecklistTile(
                    title: 'تحصیلات',
                    count: _counts['education'] ?? 0,
                    description: 'افتخارات و دروس کلیدی را ثبت کنید.',
                    onTap: () => Get.toNamed('/education'),
                  ),
                  _ChecklistTile(
                    title: 'مهارت‌ها',
                    count: _counts['skills'] ?? 0,
                    description: 'مهارت‌ها را با دسته و سطح مشخص نگه دارید.',
                    onTap: () => Get.toNamed('/skills'),
                  ),
                  _ChecklistTile(
                    title: 'پروژه‌ها',
                    count: _counts['projects'] ?? 0,
                    description: 'نقش، تاثیر و لینک‌های پروژه را وارد کنید.',
                    onTap: () => Get.toNamed('/projects'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.title,
    required this.count,
    required this.description,
    this.onTap,
  });

  final String title;
  final int count;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isComplete = count > 0;
    final color = isComplete ? Colors.green : Colors.orange;
    final icon = isComplete ? Icons.check_circle : Icons.warning_amber_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text('$title (${count.toString()})'),
        subtitle: Text(description),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
      ),
    );
  }
}
