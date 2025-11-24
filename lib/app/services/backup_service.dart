import 'dart:convert';

import 'package:sqflite/sqflite.dart';

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
import 'database_provider.dart';

class BackupService {
  BackupService({
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

  Future<String> exportToJson() async {
    final profiles = await resumeProfileRepository.getAll();
    final workExperiences = await workExperienceRepository.getAll();
    final educations = await educationRepository.getAll();
    final skills = await skillRepository.getAll();
    final projects = await projectRepository.getAll();

    final backup = {
      'resumeProfiles': profiles.map((profile) => profile.toMap()).toList(),
      'workExperiences':
          workExperiences.map((experience) => experience.toMap()).toList(),
      'educations': educations.map((education) => education.toMap()).toList(),
      'skills': skills.map((skill) => skill.toMap()).toList(),
      'projects': projects.map((project) => project.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  Future<void> importFromJson(String jsonString) async {
    final dynamic data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup structure');
    }

    final profileMaps = _validateMapList(data['resumeProfiles'], const [
      'fullName',
      'email',
      'phone',
      'summary',
    ]);
    final workExperienceMaps = _validateMapList(data['workExperiences'], const [
      'profileId',
      'company',
      'position',
      'startDate',
      'endDate',
      'description',
    ]);
    final educationMaps = _validateMapList(data['educations'], const [
      'profileId',
      'school',
      'degree',
      'fieldOfStudy',
      'startDate',
      'endDate',
      'description',
    ]);
    final skillMaps =
        _validateMapList(data['skills'], const ['profileId', 'name', 'level']);
    final projectMaps = _validateMapList(data['projects'], const [
      'profileId',
      'title',
      'description',
      'link',
    ]);

    final Database db = await DatabaseProvider.instance.database;

    await db.transaction((txn) async {
      await txn.delete(ProjectRepository.tableName);
      await txn.delete(SkillRepository.tableName);
      await txn.delete(EducationRepository.tableName);
      await txn.delete(WorkExperienceRepository.tableName);
      await txn.delete(ResumeProfileRepository.tableName);

      final Map<int, int> profileIdMap = {};

      for (final map in profileMaps) {
        final profile = ResumeProfile(
          fullName: _requireString(map, 'fullName'),
          email: _requireString(map, 'email'),
          phone: _requireString(map, 'phone'),
          summary: _requireString(map, 'summary'),
          imagePath: _optionalString(map, 'imagePath'),
          signaturePath: _optionalString(map, 'signaturePath'),
        );

        final newId = await txn.insert(
          ResumeProfileRepository.tableName,
          profile.toMap()..remove('id'),
        );

        final originalId = map['id'];
        if (originalId is int) {
          profileIdMap[originalId] = newId;
        }
      }

      for (final map in workExperienceMaps) {
        final profileId = _resolveProfileId(map, profileIdMap);
        final experience = WorkExperience(
          profileId: profileId,
          company: _requireString(map, 'company'),
          position: _requireString(map, 'position'),
          startDate: _requireString(map, 'startDate'),
          endDate: _requireString(map, 'endDate'),
          description: _requireString(map, 'description'),
        );

        await txn.insert(
          WorkExperienceRepository.tableName,
          experience.toMap()..remove('id'),
        );
      }

      for (final map in educationMaps) {
        final profileId = _resolveProfileId(map, profileIdMap);
        final education = Education(
          profileId: profileId,
          school: _requireString(map, 'school'),
          degree: _requireString(map, 'degree'),
          fieldOfStudy: _requireString(map, 'fieldOfStudy'),
          startDate: _requireString(map, 'startDate'),
          endDate: _requireString(map, 'endDate'),
          description: _requireString(map, 'description'),
        );

        await txn.insert(
          EducationRepository.tableName,
          education.toMap()..remove('id'),
        );
      }

      for (final map in skillMaps) {
        final profileId = _resolveProfileId(map, profileIdMap);
        final skill = Skill(
          profileId: profileId,
          name: _requireString(map, 'name'),
          level: _requireString(map, 'level'),
        );

        await txn.insert(
          SkillRepository.tableName,
          skill.toMap()..remove('id'),
        );
      }

      for (final map in projectMaps) {
        final profileId = _resolveProfileId(map, profileIdMap);
        final project = Project(
          profileId: profileId,
          title: _requireString(map, 'title'),
          description: _requireString(map, 'description'),
          link: _requireString(map, 'link'),
        );

        await txn.insert(
          ProjectRepository.tableName,
          project.toMap()..remove('id'),
        );
      }
    });
  }

  List<Map<String, dynamic>> _validateMapList(
    dynamic value,
    List<String> requiredKeys,
  ) {
    if (value is! List) {
      throw const FormatException('Invalid backup list');
    }

    return value.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid backup item');
      }

      for (final key in requiredKeys) {
        final field = item[key];
        if (field == null || (field is String && field.isEmpty)) {
          throw FormatException('Missing or empty field: $key');
        }
      }

      return Map<String, dynamic>.from(item);
    }).toList();
  }

  String _requireString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException('Invalid value for $key');
  }

  String? _optionalString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  int _resolveProfileId(Map<String, dynamic> map, Map<int, int> profileIdMap) {
    final originalProfileId = map['profileId'] is String
        ? int.tryParse(map['profileId'] as String)
        : map['profileId'] as int?;

    if (originalProfileId == null) {
      throw const FormatException('Invalid profile reference');
    }

    final mappedId = profileIdMap[originalProfileId];
    if (mappedId == null) {
      throw const FormatException('Missing profile reference in backup');
    }

    return mappedId;
  }
}
